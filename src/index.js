'use strict';

import { Elm } from './Main';

// https://stackoverflow.com/questions/1043339/javascript-for-detecting-browser-language-preference#answer-29106129
function getFirstBrowserLanguage() {
    var nav = window.navigator,
    browserLanguagePropertyKeys = ['language', 'browserLanguage', 'systemLanguage', 'userLanguage'],
    i,
    language;

    // support for HTML 5.1 "navigator.languages"
    if (Array.isArray(nav.languages)) {
        for (i = 0; i < nav.languages.length; i++) {
            language = nav.languages[i];
            if (language && language.length) {
                return language;
            }
        }
    }

    // support for other well known properties in browsers
    for (i = 0; i < browserLanguagePropertyKeys.length; i++) {
        language = nav[browserLanguagePropertyKeys[i]];
        if (language && language.length) {
            return language;
        }
    }

    return "";
}

window.runApp = function() {
    // lazy loading css file to support to append the css link at the end of the body
    // https://webpack.js.org/concepts/under-the-hood/#chunks
    import('./index.css').then(() => {
        const app = Elm.Main.init({
            node: document.getElementById('app'),
            // https://guide.elm-lang.org/interop/flags.html
            flags: {
                lang: getFirstBrowserLanguage(),
                height: window.innerHeight,
                width: window.innerWidth,
            }
        });
    });
}
