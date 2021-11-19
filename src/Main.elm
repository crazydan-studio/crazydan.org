module Main exposing (main)

-- https://package.elm-lang.org/packages/elm/core/latest/List
import Browser
import Browser.Events exposing (onResize)
-- https://package.elm-lang.org/packages/elm/html/1.0.0/Html
-- https://github.com/evancz/elm-todomvc/blob/master/src/Main.elm
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
-- https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/
-- https://github.com/rofrol/elm-ui-cookbook
-- Responsive:
-- - https://github.com/kodeFant/elm-ui-responsive-example/blob/master/elm-ui-solution/src/Main.elm
-- - https://discourse.elm-lang.org/t/mobile-first-elm-responsive-design-in-2019/2700/2
-- - https://github.com/opsb/cv-elm/blob/master/src/Main.elm
import Element exposing (..)
import Element.Font as Font
-- https://package.elm-lang.org/packages/elm/core/latest/Dict
import Dict exposing (Dict)
-- https://github.com/circuithub/elm-dropdown
import Dropdown


contextPath = ""
defaultLang = "zh"
defaultFontSize = 16

type alias Flags =
    { lang : String
    , width : Int
    , height : Int
    }

type alias Model =
    { lang : String
    , ui_langSwitchDropdown_toggled : Dropdown.State
    , ui_device : Device
    }

type alias LangIcon =
    { src : String
    , text : String
    }


type Msg
    = ToggleLangSwitch Bool
    | SwitchLangTo String
    | DeviceClassified Device


-- https://gist.github.com/benkoshy/d0dcd2b09f8fcc65a90b56a33dcf1465
main : Program Flags Model Msg
main =
    -- Note: Browser.sandbox is not suitable for Flags
    -- for Browser.application:
    -- - https://gist.github.com/ohanhi/fb6546263965da956f6bfce8f78349e7
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> (Model, Cmd Msg)
init flags =
    ( { lang = flags.lang
      , ui_device = Element.classifyDevice flags
      , ui_langSwitchDropdown_toggled = False
      }
      , Cmd.none
    )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    let
        newModel =
            case msg of
                ToggleLangSwitch toggled ->
                    { model | ui_langSwitchDropdown_toggled = toggled }
                SwitchLangTo lang ->
                    { model | ui_langSwitchDropdown_toggled = False, lang = lang }
                DeviceClassified device ->
                    { model | ui_device = device }
    in
    ( newModel, Cmd.none )


view : Model -> Html Msg
view model =
    Element.layout
        [ Font.size defaultFontSize
        , Font.family
            [ Font.serif
            ]
        , width fill
        , height fill
        , scrollbars
        ]
        ( showMainPanel model )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onResize
            ( \w h ->
                DeviceClassified
                    ( Element.classifyDevice { width = w, height = h } )
            )
        ]


localLangTextDict =
    Dict.fromList
        [ ( "_"
            , Dict.fromList
                [ ( "My Studio"
                    , Dict.fromList [ (
                        "zh", "我的工作室"
                    ) ]
                  )
                , ( "My Space"
                    , Dict.fromList [ (
                        "zh", "我的地盘"
                    ) ]
                  )
                ]
          )
        ]

simpleLangCode : String -> String
simpleLangCode code =
    case ( List.head (String.split "-" code) ) of
        Just s ->
            s
        Nothing ->
            code

getLocalLangText : String -> String -> String -> String
getLocalLangText md lang text =
    case ( Dict.get md localLangTextDict ) of
        Just moduleTextDict ->
            case ( Dict.get text moduleTextDict ) of
                Just langTextDict ->
                    case ( Dict.get lang langTextDict ) of
                        Just langText ->
                            langText
                        Nothing ->
                            case ( Dict.get (simpleLangCode lang) langTextDict ) of
                                Just langText ->
                                    langText
                                Nothing ->
                                    text
                Nothing ->
                    text
        Nothing ->
            text

moduleI18n : String -> String -> String
moduleI18n lang text =
    getLocalLangText "_" lang text


linkList =
    [ { url = "https://studio.crazydan.org"
      , title = "My Studio"
      }
    , { url = "https://social.crazydan.org/flytreeleft"
      , title = "My Space"
      }
    ]
showLinks i18n =
    List.map
        ( \lnk ->
            newTabLink
                [ centerX
                , paddingXY 40 0
                , Font.size 40
                , Attr.class "link"
                    |> htmlAttribute
                ]
                { url = lnk.url
                , label = text ( i18n lnk.title )
                }
        )
        linkList

showMainPanel : Model -> Element Msg
showMainPanel model =
    let
        i18n = moduleI18n model.lang
    in
    column
        [ width fill
        -- fill the content
        , height shrink
        ]
        [ el
            [ centerX, alignTop ]
            ( row [  ]
                [ image
                    [ Attr.class "logo"
                        |> htmlAttribute
                    ]
                    { src = ( contextPath ++ "asset/img/logo.svg" )
                    , description = ""
                    }
                , ( showSwitchLang model |> html )
                ]
            )
        , el
            [ centerX
            , alignTop
            ]
            ( case ( model.ui_device.class, model.ui_device.orientation ) of

                ( Phone, Portrait ) ->
                    column [ centerX, paddingXY 0 40, spacingXY 0 40 ]
                        ( showLinks i18n )

                ( _, _ ) ->
                    row [ paddingXY 0 40 ]
                        ( showLinks i18n )
            )
        ]


langIcons =
    Dict.fromList
        [ ( "zh"
            , { src = ( contextPath ++ "asset/img/flag/cn.svg" )
              , text = "中文"
            }
          )
        , ( "en"
            , { src = ( contextPath ++ "asset/img/flag/gb.svg" )
              , text = "English"
            }
          )
        ]

getLangIcon : String -> LangIcon
getLangIcon lang =
    case ( Dict.get (simpleLangCode lang) langIcons ) of
        Just icon ->
            icon
        Nothing ->
            getLangIcon defaultLang


showSwitchLang : Model -> Html Msg
showSwitchLang { lang, ui_langSwitchDropdown_toggled } =
    let
        selectedLangIcon = getLangIcon lang
        simpleLang = simpleLangCode lang
    in
    Html.div
        [ Attr.class "lang-dropdown"
        ]
        [ Dropdown.dropdown
            { identifier = "lang-dropdown"
            , toggleEvent = Dropdown.OnClick
            , drawerVisibleAttribute = Attr.class "visible"
            , onToggle = ToggleLangSwitch
            , layout =
                \{ toDropdown, toToggle, toDrawer } ->
                    toDropdown
                        Html.div
                            [ Attr.class
                                ( "dropdown"
                                    ++ ( case ui_langSwitchDropdown_toggled of
                                        True -> " toggled"
                                        _ -> ""
                                    )
                                )
                            ]
                            [ toToggle
                                Html.div
                                    [ Attr.class "toggle"
                                    ]
                                    [ Html.img
                                        [ Attr.src selectedLangIcon.src
                                        ]
                                        [  ]
                                    , Html.div [ Attr.class "arrow down" ]
                                        [  ]
                                    ]
                            , toDrawer
                                Html.div
                                    [ Attr.class "list"
                                    ]
                                    ( Dict.foldl
                                        ( \code icon acc ->
                                            acc
                                            ++ [ Html.div
                                                    [ Attr.class
                                                        ( "item"
                                                            ++ ( case ( code == simpleLang ) of
                                                                True -> " selected"
                                                                _ -> ""
                                                            )
                                                        )
                                                    , Event.onClick ( SwitchLangTo code )
                                                    ]
                                                    [ Html.img
                                                        [ Attr.src icon.src
                                                        ]
                                                        [  ]
                                                    , Html.span [  ]
                                                        [ Html.text icon.text ]
                                                    ]
                                                ]
                                        )
                                        [  ]
                                        langIcons
                                    )
                            ]
              , isToggled = ui_langSwitchDropdown_toggled
              }
        ]
