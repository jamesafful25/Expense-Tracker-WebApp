
# 1. Create Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${var.project_name}-${var.environment}-frontend-oac"
  description                       = "Secure access from CloudFront to the private S3 frontend bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Handle React single-page application routing
resource "aws_cloudfront_function" "spa_routing" {
  name    = "${var.project_name}-${var.environment}-spa-routing"
  runtime = "cloudfront-js-2.0"
  comment = "Rewrite React application routes to index.html"
  publish = true

  code = <<-EOT
    function handler(event) {
      var request = event.request;
      var uri = request.uri;

      var lastSegment = uri.substring(uri.lastIndexOf("/") + 1);

      if (lastSegment.indexOf(".") === -1) {
        request.uri = "/index.html";
      }

      return request;
    }
  EOT
}

# 2. Create the CloudFront distribution
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  comment             = "${var.project_name}-${var.environment} frontend distribution"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  # S3 frontend origin
  origin {
    domain_name              = var.frontend_bucket_regional_domain_name
    origin_id                = "S3-${var.frontend_bucket_id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }


  # ALB backend API origin
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "ALB-${var.project_name}-${var.environment}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default behavior for frontend requests
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.frontend_bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.spa_routing.arn
    }

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  # API requests go to the backend ALB
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "ALB-${var.project_name}-${var.environment}"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    compress = true

    # Disable API response caching
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

    # Forward viewer headers, cookies and query strings
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
  }


  # Use CloudFront's default HTTPS certificate
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cloudfront"
    Project     = var.project_name
    Environment = var.environment
  }
}

# 3. Allow CloudFront to read objects from the private S3 bucket
resource "aws_s3_bucket_policy" "frontend" {
  bucket = var.frontend_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"

        Principal = {
          Service = "cloudfront.amazonaws.com"
        }

        Action = [
          "s3:GetObject"
        ]

        Resource = "${var.frontend_bucket_arn}/*"

        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend.arn
          }
        }
      }
    ]
  })
}
