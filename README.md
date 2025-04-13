# `caterpie`

A small ContentAPI client targeting the "small ContentAPI" subset of the the..

## how do you build

```shell
../flutter/bin/flutter run
```

## my opinion

you gotta order the imports by "dart built-ins" "dependencies" "local things, in order of model, network, screens, then widgets" .. basically like a narrowing scope
well maybe screens should be last, because then it'd be "screens are made of widgets which can have data (maybe fetched from the network) stored in models"
