
A simple, easy to understand, CRUD application.

1. I'll open with either:
   * a verbose list of contacts, if there are 1 or more contacts,
   * a form to add a new contact, if there are no contacts.
1. In the list of contacts, if the user clicks on a contact then a modal lets the user view the contact information and select what to do.
   * Select **Edit** and the user is editing the contact in a form which allows the user to edit and submit or cancel.
   * Select **Remove** and the user is viewing the contact in a form to confirm removal or cancel removal.
   * Select **Cancel** and the user is back to the select panel.
1. I'll use sqlite to store the Contact information in a local file.

## The Front-End : crud/src/frontend/

### The Contacts screen

The **Contacts** screen will be a panel-screen with 4 panels. (A panel-screen can have multiple panels but only renders one panel at a time.)

1. **The Select panel** will display a scrolling list of contacts. Each listing is verbose containing the whole contact record. It should also have an add icon that will allow the user to switch to the **Add** panel and add a new contact.
1. The **Add** panel will display an editable contact form with an **Add** button to submit the edits. A **Cancel** button will clear the form and if there are any contact records, switch to the **Select** panel.
1. The **Edit** panel will diplay an editable contact form with an **Edit** button to submit the edit and a **Cancel** button to ignore any edits and switch to the **Select** panel.
1. The **Remove** panel will diplay a contact form with an **Remove** button to submit the record for removal. A **Cancel** button will switch to the **Select** panel.

The **Contacts** screen will default to the **Select** panel when there are one or more contacts in the store. It will default to the **Add** panel when there are no contacts in the store.

The **Contacts** screen's **messenger** will be passing the contact information between the panels and the back-end. It will also, sometimes, toggle which pannel is displayed based on information received from the back-end.

### The Choice modal screen

The **Choice** modal screen is used when a user selects a contact in the **Contacts** screen's **Select** panel. The panel presents the contact information along with button offering the user some choices. Each button triggers a call back and then closes the screen.

1. The **Choice** panel will allow the user to
   * **Edit** a contact record,
   * **Remove** a contact record
   * **Cancel** and go back to the select list.

## The Back-End : crud/src/backend/

The framework generates back-end message handlers for the messages I create at **crud/src/backend/messenger/**. I will add functionality to the message handlers.

## Dependencies : crud/src/deps/

The framework keeps it's packages that the frontend and the backend depend on, in **crud/src/deps/**. For example, the messages are kept in **crud/src/deps/messages/**.

I will add 2 of my own dependencies.

1. The **crud/deps/store/** folder will hold my store package.
1. The **crud/deps/record/** folder will store the contact records.

### Messages : crud/deps/messages/

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

### Contact Records : crud/src/deps/records/

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
   * Is a partial contact record, that contains only the record id of a contact record, selected by the user for removal.
   * Sent by the front-end to the back-end.
   * In the **RemoveContact** message.
1. The **List** record type.
   * Is a complete contact record.
   * Sent by the back-end to the front-end.
   * In the **RebuildContactList** message which contains an array of **List** records to be displayed in a select list.
   * A **List** record can be converted into an EditContact record.
   * A **List** record can be converted into a RemoveContact record.

### My local sqlite store : crud/src/deps/store/

The local sqlite store will allow me to add, update, remove a single record and select all of the records.

I'll initialize the store package in **main.zig** where I'll

1. Build the store's local file path.
1. Initialize the store.
1. Initialize the back-end with the store so it can initialize it's message handlers with the store. It is the back-end message handlers that will use the store.

## External dependencies

External dependencies are first defined in build.zig.zon and then referenced in build.zig.

### dvui

You can see those additions to the application's [[build.zig.zon|build.zig.zon]] in the appendix.

kickzig included the dvui depency in the application's [[build.zig|build.zig]] when it created the framework. So that part is already done for me.

### fridge (sqlite)

You can see those additions to the application's [[build.zig.zon|build.zig.zon]] in the appendix.

You can see those additions to the application's [[build.zig|build.zig]] in the appendix.

## Next

[[Create the Git Repo.|Create-The-Git-Repo]]
