#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

uniform float neuronRed;    // 0.440
uniform float neuronGreen;
uniform float neuronBlue;
uniform float neuronNumber;
uniform float neuronSpeedMovement;

// Variables 
const int numberNeurons = 22;
//float speedMovement = 14.504;


void main() {
    /*
    3-dimensionales Koordiantensystem
    0.5 -> Steuert inwieweit es im Ursprung liegt
    */
    vec3 st = vec3(.5) - vec3(gl_FragCoord.xy, 1) / u_resolution.y;

    vec3 p, o;
    
    //highp int n = int(neuronNumber);

    // Wie oft Neuronen gezeichnet werden
    for(int i = 0; i < numberNeurons; i++)
    {
        o = p;
        o.z -= u_time * neuronSpeedMovement;  
        float a = o.z * .1;

        /*
        Rotation des Vektors mit dem man multipliziert -> rotieren um den Winkel
        */
        o.xy *= mat2(cos(a), sin(a), -sin(a), cos(a));

        /*
        0.836: Bestimmt wie sehr die Neuronen verschwommen sind -> Je kleiner der Wert, desto verschwommener ist es 
        0.1: Bestimmt die Brreite der Neuronen
        length(cos(o.xy) + sin(o.yz)): Patternbildung -> Cos & Sin -> wenn einzelnd, dann sieht man die Kurven besser
        */
        p += (.1 - length(cos(o.xy) + sin(o.yz))) * st * neuronNumber;
    }
    
    gl_FragColor = vec4((vec3(9.000,0.158,0.760)) / length(p) * vec3(neuronRed,0.012,0.038/*neuronRed,neuronGreen,neuronBlue*/), 1.0);
}