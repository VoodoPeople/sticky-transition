# sticky-transition

### Minimum iOS version 17.0

Packege provides view modifier that makes easier to make spicky transition.

![ScreenRecording2024-07-13at11 24 59-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/3cb2707d-f01a-406f-8558-8b839ec911ce)


### Usage

```
    view.stickyInteraction(
        direction: .pullUp, 
        transitionText: pullText1, 
        onStateChange: { state in
         if state == .released {
               withAnimation(.bouncy(duration: 0.7)) {
                    toggleView.toggle()
               }
         }
     })
``` 
