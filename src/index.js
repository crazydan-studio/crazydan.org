'use strict';

import { Elm } from './Main';
import './index.css';

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

const app = Elm.Main.init({
    node: document.getElementById('app'),
    // https://guide.elm-lang.org/interop/flags.html
    flags: {
        lang: getFirstBrowserLanguage(),
        height: window.innerHeight,
        width: window.innerWidth,
    }
});

const fadeTimeout = 500;
setTimeout(() => {
    document.getElementById('loading').style.transition = (fadeTimeout / 1000.0) + 's';
    document.getElementById('loading').style.opacity = '0';

    setTimeout(() => {
        document.getElementById('loading').remove();
    }, fadeTimeout);
}, fadeTimeout * 1.2);
