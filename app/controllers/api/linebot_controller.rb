class Api::LinebotController < Api::BaseController
  protect_from_forgery with: :null_session # CSRF対策無効化

  def callback
    unless is_validate_signature
      render :nothing => true, status: 470 and return
    end
    result = params[:result][0]
    logger.info({from_line: result})
    from_mid =result['content']['from']

    client = LineClient.new(LINE_CHANNEL_ID, LINE_CHANNEL_SECRET, LINE_CHANNEL_MID, nil)
    res = client.send_messages([from_mid], [client.text(result['content']['text'])])

    if res.status == 200
      logger.info({success: res})
    else
      logger.info({fail: res})
    end

    render :nothing => true, status: :ok
  end

  private
  # LINEからのアクセスか確認.
  # 認証に成功すればtrueを返す。
  # ref) https://developers.line.me/bot-api/getting-started-with-bot-api-trial#signature_validation
  def is_validate_signature
    signature = request.headers["X-LINE-ChannelSignature"]
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, LINE_CHANNEL_SECRET, http_request_body)
    signature_answer = Base64.strict_encode64(hash)
    signature == signature_answer
  end
end
