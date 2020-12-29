// template: https://www.shadertoy.com/view/tdKXW1
// template Rotation: https://www.shadertoy.com/view/wdSXRz , https://www.shadertoy.com/view/WtByWt


#ifdef GL_ES
precision mediump float;
#endif

#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .01
#define PI 3.141592653589793

uniform vec2 u_resolution;
uniform float u_time;



mat2 rot(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}


//Formel des Blutkörperchen
float Torus(vec3 p, vec2 r){
    //Ziehen Radius ab um schlauchring zu bilden
    float x = length(p.xz)-r.x;
    return length (vec2(x,p.y))-r.y;   
}

float GetDist(vec3 p) {
    //Raymarch anhand der dinstanzfelder 1x----2x----3x----4x
    
  vec4 s = vec4(4, 1, 6, 1);
    
    float sphereDist =  length(p-s.xyz)-s.w;

    //Berechne Distanzfeld zu Torus
    float td = Torus(p-vec3(0,1,6), vec2(1.5, 1.0)); 
    float td2 = Torus(p-vec3(1,5,6), vec2(1.5, 1.0)); 
    

    //Nehme kleinsten Abstand und passe somit die Schrittweite in RayMarch an
    float d = min(td2,td);
   
    return d;
}


//Funktion für Raymarch rechnung zum schnittpunkt https://www.shadertoy.com/view/4dSfRc
float RayMarch(vec3 ro, vec3 rd) {
    float dO=1.;
    
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd*dO;

        //Bekommen Distanz zwischen Torus und vektor zurück
        float dS = GetDist(p);
        dO += dS;

        if(dO>MAX_DIST || dS<SURF_DIST) break;
    }
    

    //Gebe FAktor zurück
    return dO;
}


/*To-Do: Verstehen*/
//The normal can be calculated by taking the central difference on the distance field
vec3 GetNormal(vec3 p) {
    float d = GetDist(p);
    vec2 e = vec2(.01, 0);
    
    vec3 n = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx));
    
    return normalize(n);
}


float GetLight(vec3 p, vec3 lPos) {
    //vec3 lightPos = vec3(cos(u_time), 4.,cos(u_time));
    //vec3 lightPos = vec3(sin(u_time),2.,1.);

    //Position wo sich das Licht befinden soll
    vec3 lightPos = lPos;
   
    vec3 l = normalize(lightPos-p *.4);

    //apply diffuse lighting we have to calculate the normal of shadingpoint p 
    vec3 n = GetNormal(p);
    
    //diffuse lighting = dif
    float dif = clamp(dot(n, l), 0.0, 1.);


    //Nilufar stinkt
    //float d = RayMarch(p+n*SURF_DIST*2., l);
    //dif*= 5. /dot(lightPos -p,lightPos-p);
    //if(d<length(lightPos-p)) dif *= .1;
    
    return dif;
}

vec3 createBloodCell(vec3 ro, vec3 rd, vec3 light, vec3 col){
    
    float d = RayMarch(ro, rd );
    //endgültiger Vektor für jeden Pixel der schneidet
    vec3 p = ro + rd * d;


    float dif = GetLight(p,light);

    //return col += vec3(dif, .0, .0);
     return col += vec3(pow (dif, .60),0.,0);

}

void main()
{
    //Anpassen der Auflösung + sinus änderung für reinzoom effekt
    //compute ray direction for each pixel
    vec2 uv = (gl_FragCoord.xy - .5*u_resolution.xy)/u_resolution.xy;

    //vergrößern des Systems/Fläche/Bereich 
    uv*=2.8;
   

    vec3 col = vec3(0.0, 0.0, 0.0);

    //ray origins. punkt von dem wir aus schauen
    vec3 ro = vec3(0.,abs(1.5*sin(u_time))+3.,0.);
        
 
    //compute ray direction for each pixel

    //ändere uv vor jedem neuen
    uv = rot(u_time*2.) * uv;
    vec3 rd1 = normalize(vec3(uv.x+0.5*sin(u_time) , uv.y, 0.5)); //ray direction, horizont, vertikal, vo/zurueck

    //Licht ändert zyklisch die position
    vec3 light = vec3(0.5*sin(u_time),abs(0.5*sin(u_time))+1.,1.);
    

//Erstelle Blutkörperchen
    col = createBloodCell(ro,rd1,light,col);
 
    gl_FragColor = vec4(col,1.0);
    
}

