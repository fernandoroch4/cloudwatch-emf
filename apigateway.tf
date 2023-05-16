resource "aws_api_gateway_rest_api" "ticket" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "Ticket API"
      version = "1.0"
    }
    paths = {
      "/ticket" = {
        post = {
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "aws_proxy"
            uri                  = aws_lambda_function.create_ticket.invoke_arn
            credentials          = aws_iam_role.apigateway_integration_role.arn
          }
        }
      }
      "/ticket/{id}" = {
        patch = {
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "aws_proxy"
            uri                  = aws_lambda_function.update_ticket.invoke_arn
            credentials          = aws_iam_role.apigateway_integration_role.arn
          }
        }
        delete = {
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "aws_proxy"
            uri                  = aws_lambda_function.delete_ticket.invoke_arn
            credentials          = aws_iam_role.apigateway_integration_role.arn
          }
        }
      }
    }
  })

  name = "Ticket"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "ticket" {
  rest_api_id = aws_api_gateway_rest_api.ticket.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.ticket.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "ticket" {
  deployment_id = aws_api_gateway_deployment.ticket.id
  rest_api_id   = aws_api_gateway_rest_api.ticket.id
  stage_name    = "dev"
}

output "api_gateway_stage_uri" {
  value = aws_api_gateway_stage.ticket.invoke_url
}
