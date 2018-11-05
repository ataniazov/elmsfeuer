module Layer.Vignette exposing
    ( Model
    , Mesh
    , makeEntity
    , init
    )

import Math.Vector4 as Vec4 exposing (vec4, Vec4)
import Math.Vector3 as Vec3 exposing (Vec3, fromTuple, vec3)
import WebGL
import WebGL.Settings exposing (Setting)

import Viewport exposing (Viewport)


type alias Model =
    { opacity : Float
    , color : Color
    }


type alias Mesh = WebGL.Mesh Vertex
type alias Color = ( Float, Float, Float )



init : Model
init =
    { opacity = 1.0
    , color = ( 0.671875, 0.289, 0.5898 )
    }


makeEntity : Viewport {} -> Model -> List Setting -> WebGL.Entity
makeEntity viewport config settings =
    WebGL.entityWith
        settings
        vertexShader
        fragmentShader
        (mesh config.color)
        (uniforms viewport config)



-- Mesh


type alias Vertex =
    { position : Vec3
    , color : Vec3
    }


mesh : Color -> Mesh
mesh color =
    WebGL.triangles
        [ (
            Vertex (vec3 1 1 0) (fromTuple color)
          , Vertex (vec3 -1 1 0) (fromTuple color)
          , Vertex (vec3 -1 -1 0) (fromTuple color)
          )
         ,(
            Vertex (vec3 -1 -1 0) (fromTuple color)
          , Vertex (vec3 1 1 0) (fromTuple color)
          , Vertex (vec3 1 -1 0) (fromTuple color)
          )
        ]



-- Shaders


type alias Uniforms =
    Viewport
        { uColor : Vec3
        , uOpacity : Float
        , uResolution : Vec3
        }


uniforms : Viewport {} -> Model -> Uniforms
uniforms v { opacity, color } =
    let
        ( r, g, b ) = color
    in
    -- { perspective = Mat4.mul v.perspective v.camera }
       { rotation = v.rotation
       , perspective = v.perspective
       , camera = v.camera
       , cameraTranslate = v.cameraTranslate
       , cameraRotate = v.cameraRotate
       , size = v.size
       , origin = v.origin
       , paused = v.paused
       , uOpacity = opacity
       , uColor = vec3 r g b
       , uResolution = vec3 2340.0 1280.0 0

       }


vertexShader : WebGL.Shader Vertex Uniforms { vColor : Vec4 }
vertexShader =
    [glsl|
        precision mediump float;

        attribute vec3 position;
        attribute vec3 color;

        uniform vec3 uColor;
        varying vec4 vColor;


        void main () {
            gl_Position =  vec4(position, 1.0);
            vColor = vec4(uColor, 0.0);
        }

    |]


fragmentShader : WebGL.Shader {} Uniforms { vColor : Vec4 }
fragmentShader =
    [glsl|

        // Precision
        precision mediump float;

        uniform vec3 uColor;
        uniform float uOpacity;
        uniform vec3 uResolution;

        varying vec4 vColor;



        float vignette() {
            vec2 st = gl_FragCoord.xy/uResolution.xy;
            return distance(st,vec2(0.5));
        }


        // Main
        void main() {

            gl_FragColor.rgb = uColor;

          // gl_FragColor = vec4(uColor, vignette());
             gl_FragColor.a = mix(gl_FragColor.a , uOpacity, pow(smoothstep(0.0, 0.7, vignette()), 2.0));

        }
    |]
