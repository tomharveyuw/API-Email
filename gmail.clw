  PostWebClient.ContentType = 'message/rfc822'
  PostWebClient.Authorization = 'Bearer ' & CLIP(YOURTOKEN)

  mailBody.SetValue(CLIP(mailbodycontent)) ! mailBody is a StringTheory object
  mailBody.Base64Encode() ! optional, encoding is specified in the message headers below

  IF CLIP(attFilename) = '' ! no attachment

    PostWebClient.Post('https://gmail.googleapis.com/upload/gmail/v1/users/' & CLIP(YOURTOKEN) & '/messages/send?key=' & 'YOURAPIKEY', & |
      'MIME-Version: 1.0<10>To: '&CLIP(recipient)&'<10>From: '&CLIP(sender)&'<10>Subject: '&CLIP(subject) & | ! headers are in RFC822 plaintext format
      '<10>Content-Type: text/html; charset=utf-8<10>Content-Transfer-Encoding: base64<10><10>' & | ! body to follow is text/html encoded in base64, you can also use text/plain and unencoded transfer types 7bit or 8bit
      mailbody.GetValue())

  ELSE ! with attachment

    mailAttach.LoadFile(CLIP(attFilename)) ! mailAttach is also a StringTheory object
    mailAttach.Base64Encode() ! Base64 is required for the attachment
    stringpos = INSTRING('\',attFilename) ! strip out the path when specifying the filename in the email
    IF stringpos > 0 THEN attFilename = attFilename[stringpos : LEN(attFilename)].

    PostWebClient.Post('https://gmail.googleapis.com/upload/gmail/v1/users/' & CLIP(YOURTOKEN) & '/messages/send?key=' & 'YOURAPIKEY', & |
      'MIME-Version: 1.0<10>To: '&CLIP(recipient)&'<10>From: '&CLIP(sender)&'<10>Subject: '&CLIP(subject) & | ! headers are in RFC822 plaintext format
      '<10>Content-Type: multipart/mixed; boundary="xxyourmailpartboundxx"<10><10>' & |
      '--xxyourmailpartboundxx<10>Content-Type: multipart/alternative; boundary="xxyourmessageboundxx"<10><10>--xxyourmessageboundxx<10>' & |
      'Content-Type: text/html; charset=utf-8<10>Content-Transfer-Encoding: base64<10><10>' & |  ! body to follow is text/html encoded in base64 (see above re: options)
      mailbody.GetValue() & '<10><10>--xxyourmessageboundxx--<10>--xxyourmailpartboundxx' & |
      '<10>Content-Type: application/octet-stream<10>Content-Disposition: attachment; filename="' & CLIP(attFilename) & '"' & |
      '<10>Content-Transfer-Encoding: base64<10><10>' & |  ! attachment to follow which is encoded in base64
      mailAttach.GetValue() & '<10><10>--xxyourmailpartboundxx--')

  END

  mailbody.Free()
  mailAttach.Free()
