Crackle
=======
Crackle is an Objective-C wrapper around the 37signals Campfire API.

Functionality
-------------
Crackle covers all major endpoints provided by the Campfire API, with support for multiple accounts.

### Account

* Get info for an authorized account `GET /account.xml`

		+[CKLCampfireAPI getInfoForAccount:responseBlock:]

### Message

* Get recent messages from a room `GET /room/#{id}/recent.xml`

		+[CKLCampfireAPI getRecentMessagesForRoom:responseBlock:]
		+[CKLCampfireAPI getRecentMessagesForRoom:sinceMesssage:responseBlock:]
		+[CKLCampfireAPI getRecentMessagesForRoom:sinceMessage:withLimit:responseBlock:]

* Get messages from a room sent on a specific date `GET /room/#{id}/transcript.xml`, `GET /room/#{id}/transcript/#{year}/#{month}/#{day}.xml`

		+[CKLCampfireAPI getTodaysMessagesForRoom:responseBlock:]
		+[CKLCampfireAPI getMessagesForRoom:fromDate:responseBlock:]

* Search for messages across all rooms `GET /search?q=#{term}&format=xml`

		+[CKLCampfireAPI getMessagesWithQuery:account:responseBlock:]

* Send a message to a room `POST /room/#{id}/speak.xml`

		+[CKLCampfireAPI sendMessage:toRoom:responseBlock:]

* Toggle message starred `POST /messages/#{message_id}/star.xml`, `DELETE /messages/#{message_id}/star.xml`

		+[CKLCampfireAPI starMessage:responseBlock:]

* Stream messages from a room `GET https://streaming.campfirenow.com/room/#{id}/live.json`

    	+[CKLCampfireAPI streamMessagesInRoom:responseBlock:]

### Room

All actions are performed from the account authenticated to access the room object.

* Get visible and active rooms `GET /rooms.xml`, `GET /presence.xml`

		+[CKLCampfireAPI getVisibleRoomsForAccount:responseBlock:]
		+[CKLCampfireAPI getActiveRoomsForAccount:responseBlock:]

* Get info (including the list of users) for room `GET /room/#{id}.xml`

		+[CKLCampfireAPI getInfoForRoom:responseBlock:]

* Update room with a new name and/or topic `PUT /room/#{id}.xml`

		+[CKLCampfireAPI updateRoom:withName:topic:responseBlock:]

* Join or leave room `POST /room/#{id}/join.xml`, `POST /room/#{id}/leave.xml`

		+[CKLCampfireAPI joinRoom:responseBlock:]
		+[CKLCampfireAPI leaveRoom:responseBlock:]

* Lock or unlock room `POST /room/#{id}/lock.xml`, `DELETE /room/#{id}/lock.xml`

		+[CKLCampfireAPI lockRoom:responseBlock:]
		+[CKLCampfireAPI unlockRoom:responseBlock:]

### Upload

* Upload an image to a room `POST /room/#{id}/uploads.xml`

		+[CKLCampfireAPI uploadImage:toRoom:responseBlock:]

* Get recent uploads for room `GET /room/#{id}/uploads.xml`

		+[CKLCampfireAPI getRecentUploadsForRoom:responseBlock:]

* Get upload for specific message `GET /room/#{id}/messages/#{upload_message_id}/upload.xml`

		+[CKLCampfireAPI getUploadForMessage:responseBlock:]

### User

* Get info for current user `GET /users/me.xml`

		+[CKLCampfireAPI getInfoForUserForCurrentAccount:responseBlock:]

* Get info for specific user `GET /users/#{id}.xml`

		+[CKLCampfireAPI getInfoForUser:responseBlock:]

Authentication
--------------

Crackle uses OAuth 2 to authenticate the user with your app. Register your app’s client ID, client secret, and redirect URI with

	+[CKLCampfireAPI setClientID:secret:redirectURI:]

Then call

	+[CKLCampfireAPI authorizeWithWebView:]

to display the 37signals login form in a `UIWebView`, followed by a permission screen for allowing your app to access the user’s account. Once authentication is finished, the account’s access token is stored securely in the Keychain.

![Login Form](https://dl.dropboxusercontent.com/u/11479646/iOS%20Simulator%20Screen%20shot%20Jan%207%2C%202014%2C%201.26.47%20PM.png)
![Permission Dialog](https://dl.dropboxusercontent.com/u/11479646/iOS%20Simulator%20Screen%20shot%20Jan%207%2C%202014%2C%201.26.13%20PM.png)

Examples
--------

```objc
// Find a room to join
__block CKLCampfireRoom *room;
[CKLCampfireAPI getVisibleRoomsForAccount:account responseBlock:^(NSArray *array, NSError *error) {
    room = [array firstObject];
    // Join the room
    [CKLCampfireAPI joinRoom:room responseBlock:^(NSError *error) {
        // Stream messages from the room
        __block NSUInteger messageCount = 0;
        [CKLCampfireAPI streamMessagesInRoom:room responseBlock:^(CKLCampfireMessage *message, NSError *error) {
            // Print each message as it comes in
            if (message.body) {
                NSLog(@"%@", message.body);
                messageCount++;
            }

            // After a number of messages come in
            if (messageCount == MESSAGES_TO_STREAM) {
                // Send a message to the room
                CKLCampfireMessage *message = [CKLCampfireMessage postingMessageWithBody:@"Goodbye!" ofType:CKLCampfireMessageTypeText];
                [CKLCampfireAPI sendMessage:message toRoom:room responseBlock:^(CKLCampfireMessage *message, NSError *error) {
                    // Leave the room
                    [CKLCampfireAPI leaveRoom:room responseBlock:^(NSError *error) {
                        
                    }];
                }];
            }
        }];
    }];
}];
```

Version
-------
0.9.0

License
-------
MIT
