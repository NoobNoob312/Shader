// template: https://www.shadertoy.com/view/XsfGRn

#ifdef GL_ES
precision mediump float;
#endif


//uniforms
uniform vec2 u_resolution;
uniform float u_time;

//heart pulsation
uniform float heartSize;
uniform float heartPulsationSpeed;
uniform float heartFrequencyOfOnePulsation; 
uniform float heartSwing; 

//heart color
uniform float heartRed;
uniform float heartGreen;
uniform float heartBlue;
uniform float heartBgRed;
uniform float heartBgGreen;
uniform float heartBgBlue;


/* 
Main()
Draws two circles and pulls them down to make a heart
*/
void main() {

    vec2 st = (2.0*gl_FragCoord.xy - u_resolution.xy)/min(u_resolution.y,u_resolution.x);


// animate
    //mod(x,y): x mod y -> pulsation speed -> higher value, slower pulsation 
    float tt = mod(u_time, heartPulsationSpeed)/1.5; 

    //pow(tt,.2)*0.5+0.5= (tt^0,2)*0.5+0.5 -> Size of heart pulsation 
    float ss = pow(tt,.2)*0.5 + .5;

    /*Sinus = pulsation frequency 
    exp(x) = e^x -> low x value = smaller and slower pulsation*/
    ss = 1.0 + ss*0.5*sin(tt*6.2831* heartFrequencyOfOnePulsation + st.y*0.5)*exp(-tt*heartSwing);
    
    // coord. system/view calculated with ss frequency, heartSize and with itself -> bigger/smaller zoom 
    st *= vec2(heartSize) + ss*vec2(0.5,0.5); 




// shape
    st.y -= 0.25;   // moving y-position 
            
    /**
    atan(): Angle calculation --> atan(y, x) --> here: atan(x, y) to rotate 90 degrees, 
    /3.141593 = pi: stays in -1 to 1 interval
    **/
    float a = atan(st.x,st.y)/3.141593; 

     
    //Calculate absolut value of Vector -> a = Vector: |a| -> vector length
    float r = length(st);

    
    //y = abs(x): reflection one half of the heart
    float h = abs(a);

    // Polynom draws heartform
    float d = (12.944*h - 22.0*h*h + 10.0*h*h*h)/(6.0-5.0*h);   


    // Draw heart
    vec3 hcol = vec3(heartRed,heartGreen*st.y,heartBlue)*(1.0-0.25*length(st)); 
    vec3 color = mix( vec3(heartBgRed, heartBgGreen, heartBgBlue), hcol, smoothstep(-0.018, -0.006, d-r) );   
    gl_FragColor = vec4(color,1.0);
}