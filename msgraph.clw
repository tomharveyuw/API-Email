  PostWebClient.ContentType = 'text/plain' ! using MIME here, it can also be done via JSON
  PostWebClient.Authorization = 'Bearer ' & CLIP(YOURTOKEN)

  mailBody.SetValue(CLIP(mailbodycontent)) ! mailBody is a StringTheory object
  mailBody.Base64Encode() ! optional, encoding is specified in the message headers below

  ! mailString is another StringTheory object
  IF CLIP(attFilename) = '' ! no attachment

    mailString.SetValue('MIME-Version: 1.0<10>To: '&CLIP(recipient)&'<10>From: '&CLIP(sender)&'<10>Subject: '&CLIP(subject) & | ! headers are in RFC822 plaintext format
      '<10>Content-Type: text/html; charset=utf-8<10>Content-Transfer-Encoding: base64<10><10>' & mailBody.GetValue())          ! we have encoded the body in base64 here

  ELSE ! with attachment

    mailAttach.LoadFile(CLIP(attFilename)) ! mailAttach is also a StringTheory object
    mailAttach.Base64Encode() ! Base64 is required for the attachment
    stringpos = INSTRING('\',attFilename) ! strip out the path when specifying the filename in the email
    IF stringpos > 0 THEN attFilename = attFilename[stringpos : LEN(attFilename)].

    mailString.SetValue('MIME-Version: 1.0<10>To: '&CLIP(recipient)&'<10>From: '&CLIP(sender)&'<10>Subject: '&CLIP(subject) & | ! headers are in RFC822 plaintext format
      '<10>Content-Type: multipart/mixed; boundary="xxyourmailpartboundxx"<10><10>' & |
      '--xxyourmailpartboundxx<10>Content-Type: multipart/alternative; boundary="xxyourmessageboundxx"<10><10>--xxyourmessageboundxx<10>' & |
      'Content-Type: text/html; charset=utf-8<10>Content-Transfer-Encoding: base64<10><10>' & |                       ! body to follow is text/html encoded in base64
      mailBody.GetValue() & '<10><10>--xxyourmessageboundxx--<10>--xxyourmailpartboundxx' & |
      '<10>Content-Type: application/octet-stream<10>Content-Disposition: attachment; filename="' & CLIP(attFilename) & '"' & |
      '<10>Content-Transfer-Encoding: base64<10><10>' & mailAttach.GetValue() & '<10><10>--xxyourmailpartboundxx--')           ! the attachment is also encoded in base64

  END

  mailString.Base64Encode() ! the Microsoft Graph API requires the entire message to be encoded in base64 if sending in MIME format (some is thus double-encoded)
  PostWebClient.Post('https://graph.microsoft.com/v1.0/users/' & CLIP(USEREMAILADDRESS) & '/sendMail', CLIP(mailString.GetValue()))

  mailBody.Free()
  mailAttach.Free()
  mailString.Free()
