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
    


    //p.x = fract(p.x/4.)*4.-2.;
  
vec2 radius = vec2(0.53,0.5);


    //set torus1
    vec3 tp = p-vec3(-1.,3.,8);
    tp.yz *= rot(0.5*sin(u_time));
    tp.xy *= rot(3.*cos(u_time));
   

//set torus2
     vec3 tp2 = p-vec3(1.,4.,6);
    tp2.yz *= rot(2.*sin(u_time));
    tp2.xy *= rot(2.*cos(u_time));

//set torus3
     vec3 tp3 = p-vec3(-1.,6.,8);
    tp3.yz *= rot(1.*sin(u_time));
    tp3.xy *= rot(4.*cos(u_time));


//set torus4
     vec3 tp4 = p-vec3(1.,7.,10);
    tp4.yz *= rot(5.*sin(u_time));
    tp4.xy *= rot(2.*cos(u_time));

//set torus5
     vec3 tp5 = p-vec3(-0,5.,10);
    tp5.yz *= rot(3.1*sin(u_time));
    tp5.xy *= rot(3.*cos(u_time));


//set torus6
     vec3 tp6 = p-vec3(1.,8.,8);
    tp6.yz *= rot(4.4*sin(u_time));
    tp6.xy *= rot(6.*cos(u_time));

//set torus7
     vec3 tp7 = p-vec3(3.,6.,8);
    tp7.yz *= rot(-1.*sin(u_time));
    tp7.xy *= rot(1.*cos(u_time));


//set torus8
     vec3 tp8 = p-vec3(-3.,4.,10);
    tp8.yz *= rot(2.*sin(u_time));
    tp8.xy *= rot(6.*cos(u_time));

//set torus9
     vec3 tp9 = p-vec3(-1,8.,10);
    tp9.yz *= rot(-.1*sin(u_time));
    tp9.xy *= rot(-3.*cos(u_time));



    //Calc Distance
    float td = Torus(tp, radius); 
    float td2 = Torus(tp2, radius); 
    float td3 = Torus(tp3, radius); 
    float td4 = Torus(tp4, radius); 
    float td5 = Torus(tp5, radius); 
    float td6 = Torus(tp6, radius); 
    float td7 = Torus(tp7, radius); 
    float td8 = Torus(tp8, radius); 
    float td9 = Torus(tp9, radius); 
      

    //float planeDist = p.y; //ground plain


    //Nehme kleinsten Abstand und passe somit die Schrittweite in RayMarch an
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


//Funktion für Raymarch rechnung zum schnittpunkt https://www.shadertoy.com/view/4dSfRc
float RayMarch(vec3 ro, vec3 rd) {
    float dO=0.;

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
    //Schatten werfen
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
     return col += vec3(pow (dif, .60),0,0);

}

void main()
{
    //Anpassen der Auflösung so das 0,0 in der Mitte ist + sinus änderung für reinzoom effekt
    //compute ray direction for each pixel
    vec2 uv =1.5*(gl_FragCoord.xy - .5*u_resolution.xy)/u_resolution.y*sin(u_time);
    //vec2 uv =1.5*(gl_FragCoord.xy - .5*u_resolution.xy)/u_resolution.y;



    vec3 col = vec3(0.0, 0.0, 0.0);

    //ray origins. punkt von dem wir aus schauen
    vec3 ro = vec3(0.,2.5+3.,0.5);
        
 
    //compute ray direction for each pixel

 
    uv = rot(u_time*3.) * uv;
    vec3 rd = normalize(vec3(uv.x, uv.y, 1)); //ray direction, horizont, vertikal, vo/zurueck

    //Licht ändert zyklisch die position
    //vec3 light = vec3(0,4.,1.);
      //light.xy *= rot(u_time*3.)*uv; //Teste mit rotation mitdrehen
    
    vec3 light = vec3(1.+sin(u_time),3.+cos(u_time),1.);
  

    

//Erstelle Blutkörperchen
    col = createBloodCell(ro,rd,light,col);
    gl_FragColor = vec4(col,1.0);
    
}

