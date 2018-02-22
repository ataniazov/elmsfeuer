module Layer.Voronoi exposing (..)


import WebGL exposing (Mesh, Shader)
import WebGL.Settings exposing (Setting)
import Math.Vector3 as Vec3 exposing (Vec3, vec3, getX, getY, getZ)

import Viewport exposing (Viewport)


type alias VoronoiMesh = Mesh Vertex


type alias Config =
    {
    }


init : Config
init = {}


makeEntity : Viewport {} -> List Setting -> VoronoiMesh -> WebGL.Entity
makeEntity viewport settings mesh =
    WebGL.entityWith
        settings
        vertexShader
        fragmentShader
        mesh
        (uniforms viewport)



-- Mesh


type alias Vertex =
    { position : Vec3
    , color : Vec3
    }


build : Config -> VoronoiMesh
build _ =
    WebGL.triangles
        [ ( Vertex (vec3 0 0 0) (vec3 1 0 0)
          , Vertex (vec3 1 1 0) (vec3 0 1 0)
          , Vertex (vec3 1 -1 0) (vec3 0 0 1)
          )
        ]


-- Shaders


type alias Uniforms =
    Viewport {}


uniforms : Viewport {} -> Uniforms
uniforms v =
    -- { perspective = Mat4.mul v.perspective v.camera }
    v


vertexShader : Shader Vertex Uniforms { vcolor : Vec3 }
vertexShader =
    [glsl|

        attribute vec3 position;
        attribute vec3 color;

        uniform mat4 cameraTranslate;
        uniform mat4 cameraRotate;
        uniform mat4 perspective;
        uniform mat4 camera;
        uniform mat4 rotation;

        varying vec3 vcolor;

        void main () {
            // gl_Position = perspective * camera * rotation * cameraTranslate * cameraRotate * vec4(position, 1.0);
            // gl_Position = perspective * camera * rotation * vec4(position, 1.0);
            gl_Position = perspective * camera * rotation * vec4(position, 1.0);
            vcolor = color;
        }

    |]


fragmentShader : Shader {} Uniforms { vcolor : Vec3 }
fragmentShader =
    [glsl|

        precision mediump float;
        varying vec3 vcolor;

        void main () {
            gl_FragColor = vec4(vcolor, 1.0);
        }

    |]
