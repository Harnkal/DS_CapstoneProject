## About the algorithm

The predictive algorithm implemented in this app was inspired in the Katz Backoff model with a small difference.  

While the Katz backoff model only considers the lower a lower level ngram if the higher level ngram is not present. In this model, when calculating the probability of a word, the probability of all ngram levels is calculated, these probabilities are then adjusted according to their ngram level and the maximum value is selected.

As I am not that good with words, here goes an example. Given an trigram Katz backoff model, the probability of a word given its last 2 words would be calculated as follows:

$$
\\hat{P}(W_{i}|W_{i-2} W_{i-1}) =
\\begin{cases}
P(W_{i} | W_{i-2} W_{i-1}) & \\quad \\text{when $C(W_{i-2} W_{i-1} W_{i}) > 0$ }\\\\
\\alpha_{1}P(W_{i} | W_{i-2}) & \\quad \\text{when $C(W_{i-2} W_{i-1} W_{i}) = 0$ & $C(W_{i-1} W_{i}) > 0$}\\\\
\\alpha_{2}P(W_{i}) & \\quad \\text{otherwise}\\\\
\\end{cases}
$$

In this model, the probability of a word given its last 2 words is calculated as follows:

$$
\\hat{P}(W_{i} | W_{i-2} W_{i-1}) = \\max (P(W_{i} | W_{i-2} W_{i-1}),\\lambda P(W_{i} | W_{i-2}), \\lambda^2 P(W_{i}))
$$

This changes very little in the results as the alpha factor, which for some reason I called lambda in the package I created, unless close to or bigger than one, will prevent the probability of a lesser level to outweight the higher values.

It still happens in extreme cases though. This is what I think have brought up my accuracy from about 25% (which is close to what most of the other students have from what I've seen) to about 35%.

Besides the backoff, we also had some to cut some ngrams to allow the model to fit in this app. Only ngrams that appeared more than 2 times in the training data are considered in the model. This cutoff value is defined as k.

Finally, the number of predictions the model returns can also be selected. I arbitrarily selected 6 as the number of predictions. Of course, the more predictions I add the more accurate my model is, but at some point this starts getting quite cumbersome. 

## How it was trained

The training parameters for the model used in this app are:

 - **ngrams**: 5;
 - **lambda**: 0.25;
 - **k**: 3;
 - **npred**: 6.
 
This values were selected after a DOE experiment involving training several models and testing their accuracy. Here are the accuracy values for different numbers of predictions.

![](images/acc.png "Model accuracy on different conditions")

## About backoff model

You can learn more about backoff model through the links bellow:
 - [Smoothing and Backoff, material from the Cornel University](http://www.cs.cornell.edu/courses/cs4740/2014sp/lectures/smoothing+backoff.pdf)
 - [Katz's back-off model](https://en.wikipedia.org/wiki/Katz%27s_back-off_model)
