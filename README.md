# MyPics
This is a sample app that lets you:
* View a list of albums
* View your photos
* Take pictures and selfies and save them to Photos (Must use iPhone device) 

MyPics app uses a **UIViewControllerTransitioningDelegate** to animate the presentation of screens a user taps on from the main screen.

We use a **AVCaptureSession** to create a camera session and **AVCapturePhotoCaptureDelegate** methods to capture, process, and save the picture taken.  
