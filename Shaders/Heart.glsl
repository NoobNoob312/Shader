// template: https://www.shadertoy.com/view/XsfGRn

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

 uniform float heartSize;
uniform float heartPulsationSpeed; // 1.5
uniform float heartFrequencyOfOnePulsation; // 3.0
uniform float heartSwing; // 4.0 

// Variable
/*float size = 0.5;
float pulsationSpeed = 1.5;
float frequencyOfOnePulsation = 3.0;
float swing = 4.0;*/

// draws two circles and pulls them down to make a heart
void main() {

    vec2 st = (2.0*gl_FragCoord.xy - u_resolution.xy)/min(u_resolution.y,u_resolution.x);


// animate
    /*
    mod(x,y): x mod y -> pulsation speed -> higher value, slower pulsation -> wenn pulsationSpeed = dividend -> 0.999
    */
    float tt = mod(u_time, heartPulsationSpeed/*pulsationSpeed*/)/1.5; 

    /*
    pow(tt,.2)= tt^0,2 -> Größe des Ausschlags des Herzes 
    *0.5 = wie, wenn man durch 2 teilt --> Variavle die Einfluss auf Größe des Ausschlags Einfluss hat
    +0.5 = weitere Variable, womit die Größe des Ausschlags bestimmt werden kann
    */
    float ss = pow(tt,.2)*0.5 + .5;

    /*
    ss: 
    Sinus ist da für die Frequenz der Pulsierung 
    exp(x) = eponenziert den Wert x -> e^x -> Je größer der x-Wert, desto kleiner und langsamer ist der Ausschlag 
    -> ist zuständig für das Stocken, da ohne exp(), würde das Herz ununterbrochen schlagen
    dadurch dass der Wert tt sich zwischen 0 und -0,999 bewegt, geschieht je nach der Zeit das Pulsieren mit dem Stocken 
    -> je kleiner der Wert, desto niedriger ist der Ausschlag
    */
    ss = 1.0 + ss*0.5*sin(tt*6.2831* /*frequencyOfOnePulsation*/ heartFrequencyOfOnePulsation + st.y*0.5)*exp(-tt*/*swing*/heartSwing);
    
    /*
    Anhand der Multiplikation mit st mit sich selbst und den Werten wird das das Koordinatensystems, je nach Zeit und Frequenz vergrößert/verkleinert
    */
    st *= vec2(/*size*/heartSize) + ss*vec2(0.5,0.5); 


// shape
#if 0
    st = 0.8;
    st.y = -0.1 - st.y*1.2 + abs(st.x)(1.0-abs(st.x));
    float r = length(st);
    float d = 0.5;
#else
    st.y -= 0.25;   //  y-position from heart
    
    /**
    atan(): Winkelberechnung --> allg.: atan(y, x) --> hier: atan(x, y), damit Herz richtig rum ist
    /3.141593 = pi: bleiben im Bereich von -1 bis 1
    **/
    float a = atan(st.x,st.y)/3.141593; 

    /**
    Berechnet den Betrag vom Vektor (Satz des Pythagoras) -> a = Vektor: |a|
    Beispiel: x = 5 & y = 5 -> Wurzel(5^2 + 5^2)
    **/
    float r = length(st);

    /**
    y = abs(x): Gibt den Betrag von x zurück --> y = immer positiv, sogar wenn x negativ ist
    Beispeiel: abs(-1) = 1 & abs(1) = 1 
    --> Spiegelung der anderen Hälfte des Herzes
    **/
    float h = abs(a);

    /**
    Ploynom, dass das Herz zeichnet -> Entstehung der Herzform 
    **/
    float d = (12.944*h - 22.0*h*h + 10.0*h*h*h)/(6.0-5.0*h);   
#endif


// Margins
    /**
    mix(Start des Intervalls,  Ende des Intervalls, Wert der zwischen dem Intervall interpoliert werden soll) -> Bereiche
    smoothstep(untere Grenze, obere Grenze, Wert der zwischen den Grenzen interpoliert werden soll) -> Grenzwerte
    d-r: Bestimmt evtl. die Diagonale, damit das Herz im Koordinatensystem sichtbar ist und im Intervall liegt
    **/
    vec3 hcol = vec3(0.9,0.2*st.y,0.0)*(1.0-0.25*length(st));
    vec3 color = mix( vec3(0.015,0.009,0.040), hcol,  smoothstep(-0.018, -0.006, d-r) );
    gl_FragColor = vec4(color,1.0);
}