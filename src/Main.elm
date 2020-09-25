module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Shared exposing (Flags)
import Spa.Document as Document exposing (Document)
import Spa.Generated.Pages as Pages
import Spa.Generated.Route as Route exposing (Route)
import Url exposing (Url)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view >> Document.toBrowserDocument
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- INIT


type alias Model =
    { shared : Shared.Model
    , page : Pages.Model
    , url : Url
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        url_ = url |> Url.toString >> String.replace "index.html" ""
                   |> Url.fromString >> Maybe.withDefault url

        ( shared, sharedCmd ) =
            Shared.init flags url_ key

        ( page, pageCmd ) =
            Pages.init (fromUrl url_) shared
    in
    ( Model shared page url_
    , Cmd.batch
        [ Cmd.map Shared sharedCmd
        , Cmd.map Pages pageCmd
        ]
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | Shared Shared.Msg
    | Pages Pages.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  let
      _ = Debug.log "update" msg
  in
    case msg of
        LinkClicked (Browser.Internal url) ->
            ( { model | url = url }
            , Nav.pushUrl model.shared.key (Url.toString url)
            )

        LinkClicked (Browser.External href) ->
            ( model
            , Nav.load href
            )

        UrlChanged url ->
            let
                original =
                    model.shared

                shared =
                    { original | url = url }

                ( page, pageCmd ) =
                    Pages.init (fromUrl model.url) shared
            in
            ( { model | page = page, shared = Pages.save page shared }
            , Cmd.map Pages pageCmd
            )

        Shared sharedMsg ->
            let
                ( shared, sharedCmd ) =
                    Shared.update sharedMsg model.shared

                ( page, pageCmd ) =
                    Pages.load model.page shared
            in
            ( { model | page = page, shared = shared }
            , Cmd.batch
                [ Cmd.map Shared sharedCmd
                , Cmd.map Pages pageCmd
                ]
            )

        Pages pageMsg ->
            let
                ( page, pageCmd ) =
                    Pages.update pageMsg model.page

                shared =
                    Pages.save page model.shared
            in
            ( { model | page = page, shared = shared }
            , Cmd.map Pages pageCmd
            )


view : Model -> Document Msg
view model =
    Shared.view
        { page =
            Pages.view model.page
                |> Document.map Pages
        , toMsg = Shared
        }
        model.shared


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Shared.subscriptions model.shared
            |> Sub.map Shared
        , Pages.subscriptions model.page
            |> Sub.map Pages
        ]



-- URL


fromUrl : Url -> Route
fromUrl url =
    (Route.fromUrl >> Maybe.withDefault Route.NotFound) url
