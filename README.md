Complete Setup Guide: Portable Sales Tracker
This guide provides a comprehensive, step-by-step walkthrough for deploying the Portable Sales Tracker application. The architecture involves running a local web server within an Ubuntu virtual machine on a macOS host, with all data stored securely in your own Google Firebase project.

Part 1: Setting Up the Firebase Backend
This section covers the creation of the cloud backend that will store your data.

1.1 Create Your Firebase Project
Navigate to the Firebase Console and sign in with your Google account.

Click "Add project".

Give your project a name (e.g., "My Sales Tracker") and click Continue.

You can disable Google Analytics for this project. Click "Create project".

1.2 Enable Google Authentication
This allows you to log in to the app using your Google account.

In your Firebase project, go to the Build > Authentication section.

Click "Get started".

Select Google from the list of sign-in providers.

Enable the provider and select your email address as the Project support email.

Click Save.

1.3 Create the Cloud Firestore Database
This is where your sales opportunity data will live.

Go to Build > Firestore Database.

Click "Create database".

Start in Production mode for security. Click Next.

Choose a location for your database (one close to you is best) and click Enable.

1.4 Set Firestore Security Rules
These rules ensure only you can access your own data.

In the Firestore Database section, click the Rules tab.

Delete all the default text and replace it with this:

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write only their own documents
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}

Click the Publish button to save the rules.

Part 2: Configuring the Ubuntu VM
Now, prepare your Ubuntu virtual machine to serve the application.

2.1 Install Node.js and npm
Start your Ubuntu VM and open a terminal.

Update your package manager:

sudo apt update

Install Node.js and the Node Package Manager (npm):

sudo apt install nodejs npm -y

2.2 Install the HTTP Server
Use npm to install the http-server package globally (-g):

sudo npm install -g http-server

Part 3: Setting Up the Project Files
Place the application files inside your Ubuntu VM.

3.1 Create the Project Directory
Create a folder in a convenient location, like your Documents folder.

mkdir -p ~/Documents/SalesTracker

Navigate into that new directory:

cd ~/Documents/SalesTracker

3.2 Save the Application File
Inside the SalesTracker directory, create the HTML file:

nano sales_tracker.html

Copy the entire HTML code for the "Portable Sales Opportunity Tracker" from our chat and paste it into the nano editor.

Save and exit by pressing Ctrl+X, then Y, then Enter.

Part 4: Configuring VirtualBox Networking
This step creates a "tunnel" from your Mac to your Ubuntu VM, allowing your Mac's browser to access the server running inside the VM.

Completely shut down your Ubuntu VM.

In VirtualBox, select the VM and go to Settings > Network.

Ensure the adapter is Enabled and Attached to: NAT.

Expand the Advanced section and click Port Forwarding.

Add a new rule with the following settings:

Name: http (or any name)

Protocol: TCP

Host Port: 8080

Guest Port: 8080

Click OK to save the rule and OK again to close settings.

Part 5: Automating the Server with systemd
This creates a service that will automatically start your web server every time the Ubuntu VM boots.

5.1 Create a package.json
In your Ubuntu terminal, make sure you are in your project directory (~/Documents/SalesTracker).

Create a package.json file:

nano package.json

Paste the following content into the file. This defines a start command for your server.

{
  "name": "sales-tracker-server",
  "version": "1.0.0",
  "description": "Server for the sales tracker app.",
  "main": "sales_tracker.html",
  "scripts": {
    "start": "http-server -p 8080"
  },
  "author": "",
  "license": "ISC"
}

Save and exit (Ctrl+X, Y, Enter).

5.2 Create the systemd Service File
Create the service file using sudo:

sudo nano /etc/systemd/system/sales-tracker.service

Paste the following configuration. You must replace your_username with your actual Ubuntu username.

[Unit]
Description=Sales Tracker HTTP Server
After=network.target

[Service]
User=your_username
Group=your_username
WorkingDirectory=/home/your_username/Documents/SalesTracker
ExecStart=/usr/bin/npm start
Restart=always

[Install]
WantedBy=multi-user.target

Save and exit the file.

5.3 Enable and Start the Service
Reload the systemd daemon:

sudo systemctl daemon-reload

Enable the service to run on boot:

sudo systemctl enable sales-tracker.service

Start the service immediately:

sudo systemctl start sales-tracker.service

You can check its status with sudo systemctl status sales-tracker.service. It should show active (running).

Part 6: Final Connection and First-Time Use
This is the final step to connect everything together.

6.1 Authorize Localhost Domains
Go back to your Firebase Console > Authentication > Settings tab.

Under Authorized domains, click Add domain and add localhost.

Click Add domain again and add 127.0.0.1.

6.2 Get Your Firebase Config Keys
In your Firebase project, go to Project Settings (gear icon ⚙️).

Under the General tab, scroll to "Your apps" and click the web icon (</>).

Give the app a nickname and click "Register app".

Firebase will display your firebaseConfig keys. Keep this page open.

6.3 Connect and Run the App
On your macOS, open a web browser.

Navigate to: http://localhost:8080/sales_tracker.html

The app should load. Click the settings icon (⚙️) in the top-right.

Carefully copy and paste the keys from your firebaseConfig into the corresponding fields in the app's settings form.

Click "Save & Connect".

The page will reload, and you can now log in with Google. Your setup is complete!
===========
Creating a script to automatically run the server on boot is a great idea. The standard and most reliable way to do this on modern Linux systems like Ubuntu is to create a `systemd` service.

This guide will walk you through creating a service that automatically starts your `http-server` whenever your Ubuntu VM boots up.

-----

### **Step 1: Create a `package.json` File**

First, let's create a `package.json` file in the same directory as your `sales_tracker.html` file. This is a standard way to manage Node.js projects and define scripts.

1.  In your Ubuntu terminal, navigate to the directory where your `sales_tracker.html` is located.
    ```bash
    # Example:
    cd ~/Documents/SalesTracker
    ```
2.  Create a new file named `package.json` using the `nano` text editor:
    ```bash
    nano package.json
    ```
3.  Copy and paste the following text into the editor:
    ```json
    {
      "name": "sales-tracker-server",
      "version": "1.0.0",
      "description": "Server for the sales tracker app.",
      "main": "sales_tracker.html",
      "scripts": {
        "start": "http-server -p 8080"
      },
      "author": "",
      "license": "ISC"
    }
    ```
4.  Save the file and exit `nano` by pressing `Ctrl+X`, then `Y`, then **Enter**.

-----

### **Step 2: Create the `systemd` Service File**

Now, we'll create the service file that tells `systemd` how to run your server.

1.  Use `nano` with `sudo` to create a new service file in the correct system directory:

    ```bash
    sudo nano /etc/systemd/system/sales-tracker.service
    ```

2.  Copy and paste the following configuration into the editor. **You must change the `User` and `WorkingDirectory` lines to match your setup.**

    ```ini
    [Unit]
    Description=Sales Tracker HTTP Server
    After=network.target

    [Service]
    # IMPORTANT: Replace 'your_username' with your actual Ubuntu username
    User=your_username
    Group=your_username

    # IMPORTANT: Replace this path with the full path to your app's directory
    WorkingDirectory=/home/your_username/Documents/SalesTracker

    # This command runs the "start" script from your package.json
    ExecStart=/usr/bin/npm start

    Restart=always

    [Install]
    WantedBy=multi-user.target
    ```

      * To find your username, you can type `whoami` in the terminal.
      * To find the full path to your directory, navigate to it and type `pwd`.

3.  Save the file and exit `nano` (`Ctrl+X`, `Y`, **Enter**).

-----

### **Step 3: Enable and Start the Service**

These commands will register your new service with the system and start it.

1.  **Reload `systemd`** to make it aware of the new `sales-tracker.service` file:
    ```bash
    sudo systemctl daemon-reload
    ```
2.  **Enable the service** to make it start automatically every time you boot the VM:
    ```bash
    sudo systemctl enable sales-tracker.service
    ```
3.  **Start the service** right now (so you don't have to reboot to test it):
    ```bash
    sudo systemctl start sales-tracker.service
    ```

-----

### **Step 4: Verify the Service is Running**

You can check the status of your service at any time.

1.  To check the status, run:

    ```bash
    sudo systemctl status sales-tracker.service
    ```

    If it's working correctly, you will see a green `active (running)` message.

2.  If there are any errors, you can view the logs for your service by running:

    ```bash
    journalctl -u sales-tracker.service
    ```

That's it\! Your `http-server` will now start automatically every time you turn on your Ubuntu VM. You can access it from your Mac's browser at `http://localhost:8080/sales_tracker.html` as long as your port forwarding is set up correctly.
