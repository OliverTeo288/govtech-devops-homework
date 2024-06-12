data "aws_cloudfront_origin_request_policy" "all_viewers" {
  name = "Managed-AllViewer"
}

data "aws_cloudfront_cache_policy" "cache_disabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_distribution" "hw_cloudfront" {
  provider = aws.virginia
  origin {
    domain_name = var.alb_host_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled    = true
  web_acl_id = aws_wafv2_web_acl.hw_waf.arn
  aliases    = [var.hosted_zone_domain]

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "alb-origin"
    cache_policy_id          = data.aws_cloudfront_cache_policy.cache_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewers.id
    viewer_protocol_policy   = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["SG"]
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.cf_app_acm_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = false
  }

  tags = {
    Name = "hw-cf"
  }
}

resource "aws_wafv2_web_acl" "hw_waf" {
  provider    = aws.virginia
  name        = "hw-waf"
  description = "Web ACL for homework CloudFront distribution"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "common-rule-group"
    priority = 100

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            count {}
          }
          name = "NoUserAgent_HEADER"
        }

        rule_action_override {
          action_to_use {
            count {}
          }
          name = "SizeRestrictions_QUERYSTRING"
        }

        rule_action_override {
          action_to_use {
            count {}
          }
          name = "SizeRestrictions_Cookie_HEADER"
        }

        rule_action_override {
          action_to_use {
            count {}
          }
          name = "SizeRestrictions_BODY"
        }

        rule_action_override {
          action_to_use {
            count {}
          }
          name = "SizeRestrictions_URIPATH"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "common-rule-group"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "bad-inputs-rule-group"
    priority = 101

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "bad-inputs-rule-group"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "anon-ip-rule-group"
    priority = 102

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "anon-ip-rule-group"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "linux-rule-group"
    priority = 103

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "linux-rule-group"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "posix-rule-group"
    priority = 104

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesUnixRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "posix-rule-group"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "app-web-cf-acl"
    sampled_requests_enabled   = true
  }
  rule {
    name     = "RateLimitRule"
    priority = 105

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "rate-limit-rule"
      sampled_requests_enabled   = true
    }
  }
}