// template: tunnel https://www.shadertoy.com/view/3tB3Rw
// tunnel: https://iquilezles.org/www/articles/tunnel/tunnel.htm / https://iquilezles.org/www/articles/deform/deform.htm
// template: bloodCells/raymarching https://www.shadertoy.com/view/4dSfRc
// tutorial: https://www.shadertoy.com/view/4dSfRc


#ifdef GL_ES
precision mediump float;
#endif

//Constants for Raymarching
#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .01


#define PI 3.141592653589793


uniform vec2 u_resolution;
uniform float u_time;
uniform sampler2D u_buffer1;

//ShaderForm uniforms
uniform float bloodCellTunnelIntensity;
uniform float bloodCellRotationSpeed;
uniform float bloodCellRed;
uniform float bloodCellZoom;
uniform float bloodCellWhite;
uniform float bloodCellTunnelRotation;



//rotation matrix
mat2 rot(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}


//function for bloodcells/Torus
//https://www.youtube.com/watch?v=Ff0jJyyiVyw
float Torus(vec3 p, vec2 r){
    //subtract radius to build ring
    float x = length(p.xz)-r.x;
    return length (vec2(x,p.y))-r.y;   
}


float GetDist(vec3 p) {
    //Raymarch with dinstance fields 1x----2x----3x----4x
    
  
    //r1 and r1 of torus
    vec2 radius = vec2(0.53,0.5);

//set distance to torus middle point and set rotation for every cellpoint
    //set torus1
    vec3 tp = p-vec3(-1.,3.,8.-bloodCellZoom);
    tp.yz *= rot(0.5*sin(bloodCellRotationSpeed));
    tp.xy *= rot(3.*cos(bloodCellRotationSpeed));
   

//set torus2
     vec3 tp2 = p-vec3(1.,4.,6.-bloodCellZoom);
    tp2.yz *= rot(2.*sin(bloodCellRotationSpeed));
    tp2.xy *= rot(2.*cos(bloodCellRotationSpeed));

//set torus3
     vec3 tp3 = p-vec3(-1.,6.,8.-bloodCellZoom);
    tp3.yz *= rot(1.*sin(bloodCellRotationSpeed));
    tp3.xy *= rot(4.*cos(bloodCellRotationSpeed));

//set torus4
     vec3 tp4 = p-vec3(1.,7.,10.-bloodCellZoom);
    tp4.yz *= rot(5.*sin(bloodCellRotationSpeed));
    tp4.xy *= rot(2.*cos(bloodCellRotationSpeed));

//set torus5
     vec3 tp5 = p-vec3(-0,5.,10.-bloodCellZoom);
    tp5.yz *= rot(3.1*sin(bloodCellRotationSpeed));
    tp5.xy *= rot(3.*cos(bloodCellRotationSpeed));


//set torus6
     vec3 tp6 = p-vec3(1.,8.,8.-bloodCellZoom);
    tp6.yz *= rot(4.4*sin(bloodCellRotationSpeed));
    tp6.xy *= rot(6.*cos(bloodCellRotationSpeed));

//set torus7
     vec3 tp7 = p-vec3(3.,6.,8.-bloodCellZoom);
    tp7.yz *= rot(-1.*sin(bloodCellRotationSpeed));
    tp7.xy *= rot(1.*cos(bloodCellRotationSpeed));


//set torus8
     vec3 tp8 = p-vec3(-3.,4.,10.-bloodCellZoom);
    tp8.yz *= rot(2.*sin(bloodCellRotationSpeed));
    tp8.xy *= rot(6.*cos(bloodCellRotationSpeed));

//set torus9
     vec3 tp9 = p-vec3(-1,8.,10.-bloodCellZoom);
    tp9.yz *= rot(-.1*sin(bloodCellRotationSpeed));
    tp9.xy *= rot(-3.*cos(bloodCellRotationSpeed) );



    //Calc Distance Torus 
    float td = Torus(tp, radius); 
    float td2 = Torus(tp2, radius); 
    float td3 = Torus(tp3, radius); 
    float td4 = Torus(tp4, radius); 
    float td5 = Torus(tp5, radius); 
    float td6 = Torus(tp6, radius); 
    float td7 = Torus(tp7, radius); 
    float td8 = Torus(tp8, radius); 
    float td9 = Torus(tp9, radius); 
      

    //take min distance for next step range in ray march
    float d = min(td2,td);
    d = min(td3,d);
    d = min(td4,d);
    d = min(td5,d);
    d = min(td6,d);
    d = min(td7,d);
    d = min(td8,d);
    d = min(td9,d);

    return d;
}


//Ray March algorithm
float RayMarch(vec3 ro, vec3 rd) {
    float dO=0.; //distance origin

    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd*dO;

        //get distance between point and torus
        float dS = GetDist(p);
        dO += dS;
        

        //leaves if maximal distance is reached or distance very small
        if(dO>MAX_DIST || dS<SURF_DIST) break;
    }
    
    return dO;
}


//The normal can be calculated by taking the central difference on the distance field
vec3 GetNormal(vec3 p) {
    float d = GetDist(p);
    vec2 e = vec2(.01, 0);
    
    //get distance of near surface points
    vec3 n = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx));
    
    return normalize(n);
}


float GetLight(vec3 p, vec3 lPos) {
  

    //position of light source
    vec3 lightPos = lPos;
   
   //light vector
    vec3 l = normalize(lightPos-p *.4);

    //to apply diffuse lighting we have to calculate the normal of shadingpoint p 
    vec3 n = GetNormal(p);
    
    //diffuse lighting through dot product of unit vectors
    float dif = clamp(dot(n, l), 0.0, 1.);


    return dif;
}

vec3 createBloodCell(vec3 ro, vec3 rd, vec3 light, vec3 col){
    
    float d = RayMarch(ro, rd );
    //final Vector for pixels / surface point of object
    vec3 p = ro + rd * d;

    //add diffuse light
    float dif = GetLight(p,light);

    //return color, pow for color saturation
     return col += vec3(bloodCellRed*pow (dif, .60),dif*bloodCellWhite,dif*bloodCellWhite);

}


void main()
{


    //set 0|0 in middle
    vec2 st =1.5*(gl_FragCoord.xy - .5*u_resolution.xy)/u_resolution.y;

    vec3 col = vec3(0.0, 0.0, 0.0);

    //ray origins. point of looking
    vec3 ro = vec3(0.,2.5+3.,0.5);
        
    //rotation view
    st = (rot(bloodCellTunnelRotation*3.)) * st;
  
    //normalize to get direction
    vec3 rd = normalize(vec3(st.x, st.y, 1)); //ray direction, horizontal, vertical, back and forth

    //Licht ändert zyklisch die position
    vec3 light = vec3(1.+sin(u_time),3.+cos(u_time),1.);
  

    //create bloodcell with ray origin, ray direction, light and col
    col = createBloodCell(ro,rd,light,col);
    gl_FragColor = vec4(col,1.0);
    
   


   /*Background Tunnel*/
   //2d transformation to tunnel -> converts the cartesian coordinates to polar and then inverts the radius
    vec2 p = gl_FragCoord.xy/u_resolution.xy;
    p = (p - 0.5); //-1 to 1
    
    float depth = (p.x*p.x + p.y*p.y);
   
    // get polar coordinates   
    float angle = atan(p.x, p.y) + bloodCellTunnelRotation;

    // pack and animate    
   	vec2 t = vec2(
        angle + 0.1 / depth,
        0.33/ depth + (bloodCellTunnelRotation * 2.2)
    );
    
    float d = clamp(3.0 * depth, 0., 1.0);
   
    // fetch from texture    
    gl_FragColor += texture2D(u_buffer1, t) * vec4(d * (d * bloodCellTunnelIntensity), d, d, d);

}
