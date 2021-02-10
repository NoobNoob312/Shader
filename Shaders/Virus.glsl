// template: https://www.shadertoy.com/view/wsyyzt -> https://www.shadertoy.com/view/wsGczd
// template: Cloudy Spikeball - Duke https://www.shadertoy.com/view/MljXDw
// https://www.scratchapixel.com/lessons/3d-basic-rendering/ray-tracing-generating-camera-rays/generating-camera-rays -> Ray Erklärung



#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform sampler2D u_buffer0;

uniform float virusZoom;
uniform float virusEmergence; 
uniform float virusRotation1;
uniform float virusRotation2;
uniform float virusPosX1;
uniform float virusPosX2;


#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .01


//rotation matrix
mat2 rot(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}


// IQ's noise function 
float pn(in vec3 p){
    vec3 ip = floor(p);
    p = fract(p);
    p *= p*(3.0 - 2.0*p);
    vec2 uv = (ip.xy + vec2(37.0, 17.0)*ip.z) + p.xy;
    uv = texture2D(u_buffer0, (uv+ 0.5)/256.0, -100.0).yx;
    return mix(uv.x, uv.y, p.z);
}

// FBM
float fpn(vec3 p){
    return pn(p*.6125)*0.21*max(1.,cos(u_time)) + pn(p*.125)*0.23*cos(u_time) + pn(p*.25)*.25*cos(u_time);
}

// Spikeball. Using 16 hardcoded points, reflected to give 32 spikes in all.
//Calculate distance to spikeball surface for ray marching 
float spikeball(vec3 p) {
   
    // Ball
    float d = length(p) - 0.6;  // distance of spikeball
	float ao = (0.5 * (cos(u_time) + 1.));  // height of spike amplitude
    float o = (0.007 * ao * ao* ao);

    // Spikes
    p = normalize(p);
    
    vec4 b = max(max(max(
        abs(vec4(dot(p,vec3(0.526 + o,0.000,0.851)), dot(p,vec3(-0.526+o,0.000,0.851)),dot(p, vec3(0.851+o,0.526,0.000)), dot(p,vec3(-0.851-o,0.526,0.000)))),
        abs(vec4(dot(p,vec3(0.357*o,0.934,0.000)), dot(p,vec3(-0.357*o,0.934 * o,0.000)), dot(p, vec3(0.000,0.851,0.526)), dot(p,vec3(0.000,-0.851,0.526))))),
        abs(vec4(dot(p,vec3(0.000,0.357 + o,0.934)), dot(p,vec3(0.000,-0.357 - o,0.934)), dot(p, vec3(0.934,0.000,0.357)), dot(p,vec3(-0.934,0.000,0.357))))),
        abs(vec4(dot(p,vec3(0.577 + o,0.577 + o,0.577 + o)), dot(p,vec3(-0.577,0.577,0.577)), dot(p, vec3(0.577,-0.577,0.577)), dot(p,vec3(0.577,0.577,-0.577)))));
    b.xy = max(b.xy, b.zw);
    b.x = pow(max(b.x, b.y), 80.);  // spike thickness/ length
	

    return d - exp2(b.x*(sin(u_time+1.)*0.25 + 0.75)); 
}


// Distance function
float map(vec3 p) {
    // Performs the same as above. "rM" is produced just once, before the raymarching loop.
    mat2 rotationSp1 = rot(u_time*(1.25+virusRotation1));
    mat2 rotationSp2 = rot(u_time*(-.95-virusRotation2));


    vec3 sp1 = p+vec3(0.+virusPosX1,0,0); 
    sp1.xy *= rotationSp1;
    sp1.xz *= rotationSp1;

    vec3 sp2 = p-vec3(0.+virusPosX2,0,0);

    sp2.xy *= rotationSp2;
    sp2.xz *= rotationSp2;

    //distance to spikeball point
    float spikeball1 = spikeball(sp1) +  fpn(p*50. + u_time*15.)*0.8;

    float spikeball2 = spikeball(sp2) +  fpn(p*50. + u_time*15.)*0.8;


    float d = min(spikeball1,spikeball2);
	
    return d;
}

// See "Combustible Voronoi"
// https://www.shadertoy.com/view/4tlSzl
vec3 firePalette(float i){

    float T = 1400. + 1000.*i + 200. * (0.5 * (1. + sin(u_time))); // Temperature range (in Kelvin).
    vec3 L = vec3(7.4 * (0.5 * (sin(u_time) + 1.)), 7.6, 7.4* (0.5 * (cos(u_time) + 1.)) ); // Red, green, blue wavelengths (in hundreds of nanometers).
    L = pow(L,vec3(5.0)) * (exp(1.43876719683e5/(T*L))-1.0);
    return 1.0 - exp(-2e8/L); 
}


void main(){
  
   // p: position on the ray
   // rd: direction of the ray
   // normalize() for unit vektor = lenght 1 --> only direction relevant
   // watch from point (0, 0, -8) in direction "rd"
   vec3 rd = normalize(vec3((gl_FragCoord.xy - .5*u_resolution.xy)/u_resolution.y * virusZoom, 1.));
   vec3 ro = vec3(0., 0., -8.);
   
   // w: weighting factor
   float ld = 0.0;  // ld: local density 
   float td = 0., w;    // td: total density 

   float d = 1.0;   // d: distance function
   float t = 0.0;   // t: length of the ray/vector
   
   // Distance threshold.
   const float h = .01;
    
   // total color
   vec3 tc = vec3(0.);
    


   // ray marching loop
   for (int i=0; i<MAX_STEPS; i++) {

      if(td>(1. - 1./200.) || d<SURF_DIST || t>MAX_DIST)break;
       
      // evaluate distance function
   
      d = map(ro + t*rd); // get object min distance
      
      // check whether we are close enough (step)
      // compute local density and weighting factor 
      // const float h = .1;
      ld = (h - d) * step(d, h);
      w = (1. - td) * ld;   
     
      // accumulate color and density
      tc += w*w + 1./150.;  // Different weight distribution.
      td += w + 1./200.;

      // enforce minimum stepsize
      d = max(d, 0.04); // Increased the minimum, just a little.
      
      // step forward
      t += d*virusEmergence;
      
   }

   // Fire palette.
   tc = firePalette(tc.x);
    
   gl_FragColor = vec4(tc, 1.); 
}