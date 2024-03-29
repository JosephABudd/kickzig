# kickzig "zig and dvui my way"

## Project summary

_Whenever I begin working with a new language I like to rewrite certain programs with that new language. So here I am rewriting my kick program which was previously written in GO._

As I started learning zig, I found and started using [Dave Vanderson's dvui project](https://github.com/david-vanderson/dvui). Dvui is a very nice graphics framework that is young, easy to use and just keeps getting better.

As I continue to learn and appreciate zig and dvui, I am recreating my kick code generator to work with zig and dvui.

## March 14, 2024

* The main menu is optional.
* The front-end screens are simpler and easier to use.
* The closing down process logs the error info if there is an error.
* Added missing CLI responses.

### To do. The next big steps are

* The wiki needs to be redone.
* Spawned tabs. Tabs which can be added and removed.
* Review the closing down process.
* Review responses when `kickzig message` and `kickzig screen` commands are used before the `kickzig framework` command.

### More to do

* review CLI error and success responses.
* review source code documentation,

## kickzig is a framework code generator

Kickzig generates my version of an application framework, written in zig, using dvui. The framework is an application that is ready to build and run right away. The application has a front-end which is the gui logic and it has the back-end which is the business logic. The front-end and back-end communicate asynchronously using messages. Kickzig also adds and removes those messages.

1. The framework puts the application code at
   * «app-folder»/ (build.zig, build.zig.zon, standalone.zig, etc)
   * «app-folder»/src/@This/backend/ (back-end code)
   * «app-folder»/src/@This/frontend/ (front-end code)
   * «app-folder»/src/@This/deps/ (dependencies)
1. Vendor code can be placed in «app-folder»/src/vendor/.
1. DVUI must be cloned into «app-folder»/src/vendor/dvui/.

### Example: Creating a framework, building and running an application

The command `kickzig framework` generates the source code for a framework that is ready to run. The framework requires a vendored clone of David Vanderson's DVUI package.

```shell
＄ mkdir myapp
＄ cd myapp
＄ kickzig framework
＄ git clone https://github.com/david-vanderson/dvui.git src/vendor/dvui/
＄ zig build -freference-trace=255
＄ ./zig-out/bin/standalone-sdl
```

#### The opening. Hello World

![The app's kickzig panel example.](images/open.png)

#### The OK modal screen

![The app's OK modal screen.](images/modal.png)

#### The YesNo modal screen

![The app's YesNo modal screen.](images/yesno_modal.png)

### kickzig for the front-end

kickzig is mostly a tool for the application's front-end. The framework's front-end is a collection of screens. Each screen is a collection of panels. Panel's are displayed one at a time.

#### Screens

A screen is a collection of panels. Panels are displayed one at a time. A screen also has it's own messenger which communicates with the back-end.

Whenever you add any type of screen with kickzig, it functions perfectly.

1. A screen can be accessed from the main menu if you add it's tag ( name ) to the main menu list.
1. A screen can be content for a tab in a vertical tabbar screen. (See **Vertical tab-bar screens** below.)
1. A screen can be content for a tab in a horizontal tabbar screen. (See **Horizontal tab-bar screens** below.)

##### Panel screens

A Panel screen is the simplest type of screen. It only displays one of it's panels at any one time. Panel screens always function when you create them although the panels display the screen name and panel name by default.

`kickzig screen add-panel Edit Select Edit` creates a panel screen named **Edit** with a default panel named **Select** and another panel named **Edit**. By default the Select and Edit panels each display their screen and panel name.

`kickzig screen add-panel Remove Select Confirm` creates a panel screen named **Remove** with a default panel named **Select** and another panel named **Confirm**. By default the Select and Confirm panels each display their screen and panel name.

##### Vertical tab-bar screens

Vertical tab-bar screens have a vertical tab-bar left of where the selected tab's content is displayed. A tab's content can be one of the screen's own panels or a tab's content can be another screen.

Vertical tab-bar screens always function when you create them as long as each tab which uses an external screen is using an already existing screen. If a screen does not exist for any tab, then you need to create it before the vertical tab-bar screen will function.

`kickzig screen add-vtab ContactsV +Add Edit Remove` creates a vertical tab screen named **ContactsV** with 3 tabs. The **Add** tab has it's own panel in the screen package because I prefixed the name **Add** with **+**. The **Edit** tab uses the **Edit** screen which I created before creating this screen. The **Remove** tab uses the **Remove** screen which I created before creating this screen.

Below is the ContactsV screen with the **Edit** tab selected. Notice that the **Edit** tab is displaying the **Edit** panel-screen.

![The app's vertical tab bar screen.](images/vtab_screen.png)

##### Horizontal tab-bar screens

Horizontal tab-bar screens have a horizontal tab-bar above where the selected tab's content is displayed. A tab's content can be one of the screen's own panels or a tab's content can be another screen.

Horizontal tab-bar screens always function when you create them as long as each tab which uses an external screen is using an already existing screen. If a screen does not exist for any tab, then you need to create it before the horizontal tab-bar screen will function.

`kickzig screen add-htab ContactsH +Add Edit Remove` creates a horizontal tab screen named **Contacts** with 3 tabs. The **Add** tab has it's own panel in the screen package because I prefixed the name **Add** with **+**. The **Edit** tab uses the **Edit** screen which I created before creating this screen. The **Remove** tab uses the **Remove** screen which I created before creating this screen.

Below is the ContactsH screen with the **Remove** tab selected. Notice that the **Remove** tab is displaying the **Remove** panel-screen.

![The app's horizontal tab bar screen.](images/htab_screen.png)

##### Modal screens

Modal screens are the framework's dialogs. They are the same as panel screens where one panel is displayed at a time.

When a modal screen is to be displayed, the framwork caches the current screen before displaying the modal screen. When a modal screen is finally closed, the framework gets that cached previous screen and displays it.

The **OK** modal screen and **YesNo** modal screen are part of the framework. They also work as examples for writing other types of dialogs although they do not have a messenger. The **YesNo** modal screen is interesting because it demostrates how to use call backs.

The **EOJ** modal screen is also part of the framework. It is only used in the shutdown process.

`kickzig screen add-modal YesNoMaybe YesNoMaybe` creates a modal screen named **YesNoMaybe** with a panel named **YesNoMaybe**. It also creates a **YesNoMaybe** modal parameter for passing information to the screen's setState function.

##### Removing an unwanted screen

`kickzig screen remove YesNoMaybe` removes the screen named **YesNoMaybe**.

### DVUI tools for the developer

1. **The DVUI Debug window.** The framework's main menu allows the developer to open and use the DVUI debug window.
1. **The DVUI Demo window.** The framework's main menu also allows the developer to turn on the DVUI demo window. The actual example code is **pub fn demo() !void** in **src/vendor/dvui/src/Examples.zig**.
1. The developer can turn the above menu items off by setting `pub const show_developer_menu_items: bool = false;` in **src/@This/frontent/api.zig**.
1. **The DVUI source code.** The src code is cloned in **src/vendor/dvui/** so that it is immediately available for review.

![The app's main menu.](images/main_menu.png)

### kickzig for messages

The front-end and back-end communicate asynchronously using messages. Messages are sent and messages are received. There is no waiting for a message response. Responses happend when they happen.

#### Adding a message

* The command `kickzig message add-bf «message_name»` will add a 1 way message which the back-end «message_name» messenger sends to the front-end when triggered from anywhere in the back-end.
* The command `kickzig message add-fbf «message_name»` will add a 2 way message, that begins with amy front-end screen's messenger sending the message and expecting a response from the back-end «message_name» messenger.
* The command `kickzig message add-bf-fbf «message_name»` will add a message that is both 1 way and 2 way:

When you add a message you also add with it:

1. The message struct in deb/message/«message_name».zig.
1. The back-end messenger at backend/messenger/«message_name».zig.
1. The message channels in:
   * startup.receive_channels,
   * startup.send_channels,
   * startup.triggers.

#### Removing a message

Removing a message also removes the back-end's messenger at src/@This/backend/messenger/.

`kickzig message remove AddContact` will remove the **AddContact** message from the framework and the **AddContact** messenger at **src/@This/backend/messenger/AddContact.zig**.

#### Listing all messages

`kickzig message list` will display each message.

### Closing down the application

![The app's closing screen.](images/close.png)

#### Startup parameters

1. The startup parameter `finish_up_jobs: *_closedownjobs_.Jobs` allows modules to add their shut down call back to be executed during the closing down process.
1. The startup parameter `exit: ExitFn` is the function called only when there is a fatal error. It starts the shut down process with an error message.

#### 2 Ways to start the shut down process

1. The user clicks the window's ❎ button. The `main_loop:` in **standalone-sdl.zig** calls the closer module's `fn close(user_message: []const u8) void` which starts the closing process.
1. A software fatal error occurs. That module calls the startup parameter `exit` which starts the closing process.

#### The shut down process

The closer module has 2 important functions that do the same thing. The only difference is the modal screen heading that they use.

1. **fn exit(user_message: []const u8) void** uses the heading "Closing. Fatal Error.". The exit function is a startup parameter which is only called when there is a fatal error.
1. **fn close(user_message: []const u8) void** uses the heading "Closing". The close function is called by the `main_loop:` in **standalone-sdl.zig** when the user clicks the window's ❎ button.

##### Part 1: The front-end and back-end working together

The heading, message and close down jobs are passed to the **EOJ** modal screen. It displays it's panel with the heading and message. It does not display a button to actually stop the application because the shut down process has only begun.

The **EOJ** screen's messenger passes the list of close down jobs to the backend using the `CloseDownJobs` message.

As the back-end `CloseDownJobs` messenger runs each job it reports it's progress back to the front-end using the `CloseDownJobs` message.

At the front-end the **EOJ** modal screen's messenger receives each message from the back-end. The messenger passes each update to the **EOJ** panel to be displayed.

When the back-end finally reports that the all of the jobs are completed:

1. If a fatal error causes the close then the **EOJ** panel displays the close button. That way the user can see the closing screen and understand that an error has occured. The user can then click the close button to close the application once and for all.
1. If the user closed the app by clicking on the window's ❎ button, then the app closes for the user.
