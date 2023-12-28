
A simple, easy to understand, CRUD application.

1. I'll open with
   * a verbose list of contacts if there are any,
   * or the add a new contact screen if there are no contacts.
1. In the list of contacts, if the user clicks on a contact then a modal lets the user view the contact information and select what to do.
   * Edit, Remove, Cancel.
1. Records can be stored in a sqlite file.

## The front-end

### The Contacts screen

The **Contacts** screen will be a panel-screen with 4 panels. _A panel-screen can have multiple panels but only renders one panel at a time._ If there are contacts then the **Select** panel will be the default panel. If there are no consact records then the **Add** panel will be the default panel.

1. **The Select panel** will display a scrolling list of contacts. Each listing is verbose containing the whole contact record. It should also have an add icon that will allow the user to switch to the **Add** panel and add a new contact.
1. The **Add** panel will display an editable contact form with an **Add** button to submit the edits. A **Cancel** button will clear the form and if there are any contact records, go back to the **Select** panel.
1. The **Edit** panel will diplay an editable contact form with an **Edit** button to submit the edit and a **Cancel** button to ignore any edits and go back to the **Select** panel. A **Cancel** button will switch to the **Select** panel.
1. The **Remove** panel will diplay an editable contact form with an **Remove** button to submit the record for removal. A **Cancel** button will switch to the **Select** panel.

The **Contacts** screen's **messenger** will be passing the contact information between the panels and the back-end. It will also, sometimes, toggle which pannel is displayed based on information received from the back-end.

### The Choice modal screen

The **Choice** modal screen is used when a user selects a contact in the **Contacts** screen's **Select** panel. The panel presents the user choices using buttons. Each button triggers a call back and then closes the screen.

1. The **Choice** panel will allow the user to
   * **Edit** a contact record,
   * **Remove** a contact record
   * **Cancel** and go back to the select list.

## Dependencies

Dependencies are the packages that I write. I'll put them in the framework's **src/@This/deps/** folder.

### Messages

1. The **RebuildContactList** message.
   * Is a command from the back-end to the front-end.
   * Is is a command to rebuild Contact lists.
   * There is no returned message from the front-end.
1. The **AddContact** message.
   * Is a request from the front-end to the back-end.
   * It is a request to submit a new user added Contact record.
   * The back-end returns the message with a possible error message.
   * The back-end also sends a **RebuildContactList** message.
1. The **EditContact** message.
   * Is a request from the front-end to the back-end.
   * It is a request to submit a user edited Contact record.
   * The back-end returns the message with a possible error message.
   * The back-end also sends a **RebuildContactList** message.
1. The **RemoveContact** message.
   * Is a request from the front-end to the back-end.
   * It is a request to remove a user selected Contact record.
   * The back-end returns the message with a possible error message.
   * The back-end also sends a **RebuildContactList** message.

### Contact Records

The Contact records are required for the messages. Each type of message requires a specific type of Contact record.

1. The **Add** record type.
   * Is a partial contact record, edited by the user, that contains no contact record id.
   * Sent by the front-end to the back-end.
   * In the **AddContact** message.
1. The **Edit** record type.
   * Is a complete contact record, edited by the user, that contains the original record id.
   * Sent by the front-end to the back-end.
   * In the **EditContact** message.
1. The **Remove** record type.
   * Is only a contact record id of a contact record selected by the user.
   * Sent by the front-end to the back-end.
   * In the **RemoveContact** message.
1. The **List** type.
   * Is a complete contact record.
   * Sent by the back-end to the front-end.
   * In the **RebuildContactList** message which contains an array of **List** records to be displayed in a select list.
   * A **List** record can be converted into an EditContact record.
   * A **List** record can be converted into a RemoveContact record.

### My local sqlite store

The local sqlite store will allow me to add, update, remove a single record and select all of the records.

I'll initialize the store package in **standalone-sdl.zig** where I'll

1. Build the file path.
1. Initialize the store.
1. Initialize the back-end with the store so it can initialize it's message handlers with the store. It is the back-end message handlers that will use the store.

## Vendors

Vendors are the dependencies cloned from repos. The vendor folder is at **src/vendor/**.

1. kickzig's default settings required me to clone dvui into the vendor folder.
1. I'm going to also clone [Super Auguste et al's known-folders package](https://github.com/ziglibs/known-folders) into the vendor folder.
1. I'm going to also clone [LeRoyce Pearson's sqlite-zig package](https://github.com/leroycep/sqlite-zig.git) into the vendor folder.

## Next

[[Create the Git Repo.|stepbystep/Create-The-Git-Repo]]
