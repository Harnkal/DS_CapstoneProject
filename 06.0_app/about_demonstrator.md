## About the App

This app was created in order to demonstrate the algorithm trained by me using the ngkm library that I created.

## How it Works

This app is very simple and is basically divided in three areas that are explained below.

### Input
You can start typing in the input area and whenever you hit space the app will try to predict what is the next word you are going to type in the output area.

### Output
The output area contains two sets of information:
 - **Input tokens**: the set of tokens that are being used as predictors in the exact form they are presented to the model. You can observe that there are several changes between the input you typed and the input tokens (Eg. if you enter a number the token *"\<no\>"* will appear).
 - **Predictions**: this is were the predictions from the algorithm are going to appear in the form of a plot. You can click on the plot to select the word that you want to insert and it will be inserted at the end of you text, you may notice that any leading, trailing and consecutive spaces are removed from the input text as you insert a prediction (this is intentional as spaces are important for the correct behavior of the app).
 
### Control Panel
In the control panel you can:
 - Change the **lambda** of the model (more on that at the *About the Algorithm* section), which may change the predictions.
 - **Activate the nonsense mode** which makes the app automatically include a word whenever you press space. The word to be included is selected from the predictions following one of the *nonsense mode types*
 - **Nonsense mode types** controls the behavior of the nonsense mode, they are pretty much selfexplanatory, exept the carousel which circles between the prediction order.
 - **Restart** the app to its initial state.


