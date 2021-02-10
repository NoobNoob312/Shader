#ifdef GL_ES
precision mediump float;
#endif
#define PI 3.141592653589793
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform float skEyeColorR;
uniform float skEyeColorG;
uniform float skEyeColorB;
uniform float skColor;
uniform float skMovement;


vec3 eyeColor = vec3(skEyeColorR,skEyeColorG, skEyeColorB); 
vec3 white = vec3(0.975,0.975,0.975);
vec3 black = vec3(0.010,0.010,0.010);
vec3 skullColor = vec3(skColor);


float rectFunc(float x, float from, float to)
{
    return step(from, x) - step(to, x);
}


 //rectangle draw function
vec3 drawPixelsFreq(vec2 uv, float xStart, float xStop, float yStart, float yStop, vec3 paint, vec3 c, float time){
   float xPixel = rectFunc(uv.x,xStart,xStop);
   float yPixel = rectFunc(uv.y,yStart+time,yStop+time);
   vec3 color = mix(c, paint, xPixel*yPixel);
   return color;
}
 
void main() {

    //white background
    vec3 color = black;
 
 
    float freqKiefer = abs(1.6*sin(u_time *3.)*skMovement);
    float freqRest = abs(2.6*sin(u_time *3.)*skMovement);
 
  vec2 uv = gl_FragCoord.xy / u_resolution;

   float pixelCount = 21.;
    uv = uv *pixelCount;
  
    uv -= vec2(10);
    uv += vec2(10);

//Knochen linksOben
color = drawPixelsFreq(uv, 5., 6., 14.,15., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 4.,5., 15.,16., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 2., 4., 16.,17., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 3., 4., 17.,18., skullColor, color, freqRest);

 
//Knochen rechts oben
 color = drawPixelsFreq(uv, 15., 16., 14.,15., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 16.,17., 15.,16., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 17., 19., 16.,17., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 17., 18., 17.,18., skullColor, color, freqRest);
 
 
 
    //Knochen rechts unten
 color = drawPixelsFreq(uv, 15., 16., 7.,8., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 16.,17., 6.,7., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 17., 19., 5.,6., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 17., 18., 4.,5., skullColor, color, freqRest);
 
   //Knochen links unten
 color = drawPixelsFreq(uv, 5., 6., 7.,8., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 4.,5., 6.,7., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 2., 4., 5.,6., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 3., 4., 4.,5., skullColor, color, freqRest);
   
//Stirn
//Zeile 14
color = drawPixelsFreq(uv, 7., 14., 14.,15., skullColor, color, freqRest);
//Zeile 13
color = drawPixelsFreq(uv, 6., 15., 13.,14., skullColor, color, freqRest);
//Zeile 12
color = drawPixelsFreq(uv, 5., 16., 12.,13., skullColor, color, freqRest);
 
//Augenbereich
//Zeile 11
color = drawPixelsFreq(uv, 5., 8., 11.,12., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 9., 12., 11.,12., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 13., 16., 11.,12., skullColor, color, freqRest);
 
//Zeile10
color = drawPixelsFreq(uv, 5., 7., 10.,11., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 10., 11., 10.,11., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 14., 16., 10.,11., skullColor, color, freqRest);
 
//Zeile9
 color = drawPixelsFreq(uv, 5., 7., 9.,10., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 9., 12., 9.,10., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 14., 16., 9.,10., skullColor, color, freqRest);
 
 
//Augenfarbe
//Auge links
 color = drawPixelsFreq(uv, 8.,9.,11.,12., eyeColor, color, freqRest );
 color = drawPixelsFreq(uv, 7.,10.,10.,11., eyeColor, color, freqRest );
 color = drawPixelsFreq(uv, 7.,9.,9.,10., eyeColor, color, freqRest );
 


//Auge recht
 color = drawPixelsFreq(uv, 12.,13.,11.,12., eyeColor, color, freqRest );
 color = drawPixelsFreq(uv, 11.,14.,10.,11., eyeColor, color, freqRest );
 color = drawPixelsFreq(uv, 12.,14.,9.,10., eyeColor, color, freqRest );




//Kiefer Oben
//Zeile8
 color = drawPixelsFreq(uv, 6., 10., 8.,9., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 11., 15., 8.,9., skullColor, color, freqRest);
//Zeile7
color = drawPixelsFreq(uv, 8., 13., 7.,8., skullColor, color, freqRest);
//Zeile6
color = drawPixelsFreq(uv, 8., 9., 6.,7., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 10., 11., 6.,7., skullColor, color, freqRest);
color = drawPixelsFreq(uv, 12., 13., 6.,7., skullColor, color, freqRest);
 
//Kiefer unten
//Zeile4
color = drawPixelsFreq(uv, 7., 8., 4.,5., skullColor,  color,freqKiefer);
color = drawPixelsFreq(uv, 9., 10., 4.,5., skullColor,  color,freqKiefer);
color = drawPixelsFreq(uv, 11., 12., 4.,5., skullColor,  color,freqKiefer);
color = drawPixelsFreq(uv, 13., 14., 4.,5., skullColor,  color,freqKiefer);
//Zeile3
color = drawPixelsFreq(uv, 7., 14., 3.,4., skullColor,  color,freqKiefer);
//Zeile2
color = drawPixelsFreq(uv, 8., 13., 2.,3., skullColor,  color,freqKiefer);
 



  
    gl_FragColor = vec4(color, 1.0);
}
