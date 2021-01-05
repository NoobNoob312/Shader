// template: https://www.shadertoy.com/view/wsyyzt -> https://www.shadertoy.com/view/wsGczd
// https://www.scratchapixel.com/lessons/3d-basic-rendering/ray-tracing-generating-camera-rays/generating-camera-rays -> Ray Erklärung

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform sampler2D u_buffer0;

uniform float virusZoom;
uniform float virusEmergence; // 0.5 /*0,2 bzw 0,3 für super coolen leucht effekt*/
uniform float virusRotation1;
uniform float virusRotation2;
uniform float virusPosX1;
uniform float virusPosX2;




/*

	Fiery Spikeball
	---------------

	Making some modifications to Duke's "Cloudy Spikeball" port to produce a fiery version.

	I trimmed the original shader down a bit, changed the weighting slightly, made a couple of 
	sacrifices to the spike shape to tighten up the distance equation, etc.


	Cloudy Spikeball - Duke
	https://www.shadertoy.com/view/MljXDw

    // Port from http://glslsandbox.com/e#1802.0, with some modifications.
    //--------------
    // Posted by Las
    // http://www.pouet.net/topic.php?which=7920&page=29&x=14&y=9
	// By the way, the demo is really good. Definitely worth watching.


*/

mat2 rot(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}



// IQ's noise
// TODO verstehen -> nur nilu -> rolf will das nicht verstehen -> Rolf: "Viellleicht sollte man wissen was noise ist"
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
float spikeball(vec3 p) {
   
    // Ball
    float d = length(p) - 0.6;  // Nähe des Balls
	float ao = (0.5 * (cos(u_time) + 1.));  // Größe der Spikes inwieweit diese "ausschlagen" -> implizit manche stärker ausschlagen
    float o = (0.007 * ao * ao* ao);

    // Spikes
    p = normalize(p);
    
    // innerste max: Zeile 1 & 2 -> das Größere wird genommen und dann mit der dritten Zeile im mittleren max verglichen
    // Dieser Wert mit der vierten Zeile verglichen -> Größter Wert wird genommen
    vec4 b = max(max(max(
        abs(vec4(dot(p,vec3(0.526 + o,0.000,0.851)), dot(p,vec3(-0.526+o,0.000,0.851)),dot(p, vec3(0.851+o,0.526,0.000)), dot(p,vec3(-0.851-o,0.526,0.000)))),
        abs(vec4(dot(p,vec3(0.357*o,0.934,0.000)), dot(p,vec3(-0.357*o,0.934 * o,0.000)), dot(p, vec3(0.000,0.851,0.526)), dot(p,vec3(0.000,-0.851,0.526))))),
        abs(vec4(dot(p,vec3(0.000,0.357 + o,0.934)), dot(p,vec3(0.000,-0.357 - o,0.934)), dot(p, vec3(0.934,0.000,0.357)), dot(p,vec3(-0.934,0.000,0.357))))),
        abs(vec4(dot(p,vec3(0.577 + o,0.577 + o,0.577 + o)), dot(p,vec3(-0.577,0.577,0.577)), dot(p, vec3(0.577,-0.577,0.577)), dot(p,vec3(0.577,0.577,-0.577)))));
    b.xy = max(b.xy, b.zw);
    b.x = pow(max(b.x, b.y), 80.);  // Bestimmt die Stachelbreite/Stachellänge
	
    // exp2(x): 2^x
    return d - exp2(b.x*(sin(u_time+1.)*0.25 + 0.75)); // Gibt die Distanz der Vektorlänge der Spikes an
}


// Distance function
float map(vec3 p) {
    // Performs the same as above. "rM" is produced just once, before the raymarching loop.
    // I think it'd be faster, but GPUs are strange, so who knows.
    // Duke tells me that "r *= rM" can break in some older browsers. Hence, the longhand.
    mat2 rotationSp1 = rot(u_time*(1.25+virusRotation1));
    mat2 rotationSp2 = rot(u_time*(-.95-virusRotation2));


    vec3 sp1 = p+vec3(0.+virusPosX1,0,0); 
    sp1.xy *= rotationSp1;
    sp1.xz *= rotationSp1;

    vec3 sp2 = p-vec3(0.+virusPosX2,0,0);

    sp2.xy *= rotationSp2;
    sp2.xz *= rotationSp2;

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
    return 1.0 - exp(-2e8/L); // Exposure level. Set to "50." For "70," change the "5" to a "7," etc.
}


void main(){
  
   // p: position on the ray
   // rd: direction of the ray
   // Reversed the Z-coordinates to see the virus
   // Benutzen normalize() (Einheitsvektor = Länge 1), da in diesem Fall nur die Richtung relevatn ist & diese soll unabhängig von der Länge des Vektors sein
   // Betrachte von dem Punkt (0, 0, -8) den Virus in der Richtung "rd"
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
    

    
   // Tidied the raymarcher up a bit. Plus, got rid some redundancies.

   // rm loop
   for (int i=0; i<64*64*64; i++) {

      // Loop break conditions. Seems to work, but let me know if I've 
      // overlooked something. The middle break isn't really used here, but
      // it can help in certain situations.
      if(td>(1. - 1./200.) || d<0.001*t || t>1200.)break;
       
      // evaluate distance function
      // Took away the "0.5" factor, and put it below. 
      d = map(ro + t*rd); // Solange Vektor verlängern bis Punkt trifft
      
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
      t += d*virusEmergence;//virusEmergence;
      
   }

   // Fire palette.
   tc = firePalette(tc.x);
    
   // No gamma correction. It was a style choice, but usually, you should have it.   
   gl_FragColor = vec4(tc, 1.); //vec4(tc.x+td*2., ld*3., 0, tc.x);
}