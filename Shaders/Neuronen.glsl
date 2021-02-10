//template:https://www.shadertoy.com/view/3d2cRV

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

uniform float neuronRed;   
uniform float neuronRedIntensitiy; 
uniform float neuronGreen; 
uniform float neuronBlue;  
uniform float neuronSpeedMovement;


const int numberNeurons = 22;

void main() {
    //3-dim. coord. and origin at 0.5
    vec3 st = vec3(.5) - vec3(gl_FragCoord.xy, 1) / u_resolution.y;

    vec3 p, o;

    
    for(int i = 0; i < numberNeurons; i++)
    {
        o = p;
        o.z -= u_time * neuronSpeedMovement;  
        float a = o.z * .1;


        //Rotation Matrix
        o.xy *= mat2(cos(a), sin(a), -sin(a), cos(a));

        /*
        0.1: thickness of neurons
        length(cos(o.xy) + sin(o.yz)): Pattern building -> Cos & Sin*/
        p += (.1 - length(cos(o.xy) + sin(o.yz))) * st;
    }
    
    gl_FragColor = vec4((vec3(neuronRedIntensitiy,neuronGreen,neuronBlue)) / length(p) * vec3(neuronRed,neuronGreen,neuronBlue), 1.0);
}