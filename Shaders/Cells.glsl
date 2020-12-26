// template: https://www.shadertoy.com/view/Wtffzn
// https://thebookofshaders.com/12/?lan=de -> Erklärung Voronoi
#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//uniform float cellDiffusion; // 0.5
//uniform float cellZoom;

vec3 backgroundColor = vec3(0.0);

vec2 random( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

void main()
{
    float cellDiffusion = 0.5;
    float cellZoom = 10.0;

    // Normalized pixel coordinates (from 0 to 1)
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.y *= u_resolution.y/u_resolution.x;    // Anpassung des Verhältnisses der Fenstergröße -> (Keine Verzerrung)
    
    //tile
	st *= cellZoom;  // Je mehr der Wert des cellZooms größer ist, umso mehr Zellen sieht man -> 0 - 10
    vec2 i_st = floor(st);  // floor(x): Findet den nächsten Integer, kleiner oder gleich x -> Gibt an welche Kachel zwischen 0 und 10
    vec2 f_st = fract(st);  // fract(x): nimmt den hinteren Kommateil -> Gibt Position innerhalb der Kachel an
    vec3 col = vec3(0.0, 0.0, 0.0);
    
    
    //cell
    float m_dist = 1.;  // Minimum Distanz
    
    for(int y = -1; y <= 1; y++)
    {
        for(int x = -1; x <= 1; x++)
        {
            vec2 neighbor = vec2(float(x), float(y)); // Nachbar Position im Raster
            
            vec2 point = random(i_st + neighbor); // Zufällige Position vom aktuellen + Nachbarposition im Raster
            
            point = vec2(.5) + .5 * (sin(u_time + 6.075 * point)); // u_time: cells movement from point is between 0 and 1
                   
            vec2 diff = neighbor + point - f_st; // Vektor zwischen dem Pixel und dem Punkt
            
            float dist = length(diff); // Distance to the point
            
            m_dist = min(m_dist, dist); // min(x, y): Gibt den kleineren Wert von den beiden zurück -> Nimm die nähere Distanz  
        }
    }

    // Bedeutung von - & + bei col: Bestimmt ob die Kante oder die Fläche rot oder weiß ist
    col += m_dist;  // Zeichne Minimum Distanz (Distanz Feld)
    col -= clamp(sin(1.*m_dist), 0., 1.) * cellDiffusion;   // min(max(sin(1.*m_dist), minVal), maxVal) -> Gibt Werte zwischen 0 und 1 aus; Alles über 1 = 1 & alles unter 0 = 0
    
    col.r += 1.85;  
    col.b += .25;   
    col.g += .25; 
  
    // Output to screen
    gl_FragColor = vec4(col, 1.0);
}
        
        
