# API-Email
Code I developed for POSTing emails to Google Gmail and Microsoft Graph (Outlook.com) APIs without using their libraries, because those don't exist for Clarion. 

Using raw RFC822/2822/5322 MIME format. JSON is also possible. 

This is accomplished here by using the commercial NetTalk library for Clarion (Win32), although it 
could be modified to be done via other methods (eg. CURL). 

I'm not including the OAuth portions, as NetTalk largely takes care of that with proper configuration. 

You will need to create a developer account for each service, and get approved for the minimum 
scope needed to send emails on behalf of a user. 

For Gmail, you'll need a Google Developer account, with an "app" set up for OAuth in there. 
You can start with a test platform, and publish it afterwards.

You'll ultimately need to get authorized/approved for this Google API scope:
https://www.googleapis.com/auth/gmail.send

For Microsoft, you'll need a Microsoft Developer account (https://portal.azure.com/), 
and again you'll need to create an "app" to get OAuth set up in there. 

You'll need to set it to access this MS Graph API scope:
https://graph.microsoft.com/Mail.Send

Beyond that, just take the regular NetTalk POST function and put this stuff in, 
substitute your API Key and token values where indicated in ALL CAPS. 
