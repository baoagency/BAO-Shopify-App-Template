# frozen_string_literal: true

class GraphqlController < AuthenticatedController
  def proxy
    response = proxy_query(headers: request.headers.to_h, body: request.body.read)

    render(json: response.body, status: response.code.to_i)
  rescue => e
    message = "Failed to run GraphQL proxy query: #{e.message}"

    code = e.is_a?(ShopifyAPI::Errors::HttpResponseError) ? e.code : 500

    logger.info(message)
    render(json: message, status: code)
  end

  private

  def proxy_query(headers:, body:, cookies: nil, tries: 1)
    raise Errors::PrivateAppError, "GraphQL proxying is unsupported for private apps." if ShopifyAPI::Context.private?

    normalized_headers = ShopifyAPI::Utils::HttpUtils.normalize_headers(headers)

    session = ShopifyAPI::Utils::SessionUtils.load_current_session(
      auth_header: normalized_headers["authorization"],
      cookies: cookies,
    )

    if session.nil?
      raise Errors::SessionNotFoundError,
        "Failed to load an session from the provided parameters."
    end

    client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)

    case normalized_headers["content-type"]
      when "application/graphql"
        return client.query(query: body, tries: tries)
      when "application/json"
        parsed_body = JSON.parse(body)

        query = parsed_body["query"]
        raise ShopifyAPI::Errors::InvalidGraphqlRequestError,
          "Request missing 'query' field in GraphQL proxy request." if query.nil?

        return client.query(query: query, variables: parsed_body["variables"], tries: tries)
    end

    raise ShopifyAPI::Errors::InvalidGraphqlRequestError, "Unsupported Content-Type #{normalized_headers["content-type"]}."
  end
end
