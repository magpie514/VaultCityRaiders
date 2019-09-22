using Godot;
public class CellularAutomaton: Object {
	// Standard data ///////////////////////////////////////////////////////////
	protected string name = "NULL";
	protected byte[][,] map;  //Our board or map.
	public byte cells    = 0; //Which map index to use.
	protected int width  = 1;
	protected int height = 1;
	protected byte[] states;  //List of states. Define them with constants first!
	protected bool[] glows;   //Cells that are to be drawn glowing.
	protected Color[] colors; //Colors for the various cell states.
	protected byte no_op;     //This state is ignored for updates.
	// Helpers /////////////////////////////////////////////////////////////////
	// Moore neighborhood, Golly ordering        N NE E SE S SW W NW
	protected readonly int[][] moore      = { new int[2] { 0, 1}, new int[2]{ 1, 1}, new int[2] { 1, 0}, new int[2] { 1,-1},  new int[2] { 0,-1}, new int[2] { -1,-1}, new int[2] { -1, 0}, new int[2] { -1, 1} };
	// Von Neumann neighborhood, Golly ordering  N E S W
	protected readonly int[,] von_neumann = { { 0, 1}, { 1, 0}, { 0,-1}, {-1, 0} };

	virtual public void init(byte w, byte h, Godot.Collections.Dictionary vis) {
		width = w; height = h;
		map = new byte[3][,];
		map[0] = new byte[h+1, w+1];
		map[1] = new byte[h+1, w+1];
		map[2] = new byte[h+1, w+1];
		cells = 0;
		Godot.Collections.Dictionary temp;
		foreach(byte i in states){
			temp = (Godot.Collections.Dictionary)vis[i];
			colors[i] = (Color)temp["color"];
		}
	}
	public void cell_set(byte x, byte y, byte val) { //Public method to set a cell state from gdscript.
		map[cells][y, x] = val;
	}
	public int cell_get(byte x, byte y){ //Public method to obtain a cell's state from gdscript.
		return map[cells][y, x];
	}
	public void step(){ //Updates the board.
		int old = cells;  //Keep track of the previous map.
		if(cells == 0) cells = 1;
		cells = (byte)(cells == 1 ? 2 : 1); //Switches current map so no new maps are generated.
		for(byte y = 0; y < height; y++){
			for(byte x = 0; x < width; x++){
				if(map[old][y, x] != no_op) map[cells][y, x] = rules(map[old], x, y);
				else map[cells][y, x] = map[old][y, x];
			}
		}
	}
	public void step_draw(Image img, Image img_glow){
		int old = cells;  //Keep track of the previous map.
		if(cells == 0) cells = 1;
		cells = (byte)(cells == 1 ? 2 : 1); //Switches current map so no new maps are generated.
		byte cell = 0;
		for(byte y = 0; y < height; y++){
			for(byte x = 0; x < width; x++){
				if(map[old][y, x] != no_op) cell = rules(map[old], x, y);
				else cell = map[old][y, x];
				map[cells][y, x] = cell;
				if(cell != 0){
					if (glows[cell]) img_glow.SetPixel(x, y, colors[cell]);
					else img.SetPixel(x, y, colors[cell]);
				}
			}
		}
	}
	public void reset(){ //Resets a board.
		for(byte y = 0; y < height; y++){
			for(byte x = 0; x < width; x++){
				map[cells][y, x] = map[0][y, x];
			}
		}
		cells = 0;
	}
	public void clear(){ //Completely erases the contents of the board.
		//Array.Clear(map[cells], 0, map[cells].Length); //.net only?
		cells = 0;
		for(byte y = 0; y < height; y++){
			for(byte x = 0; x < width; x++){
				map[cells][y, x] = 0;
			}
		}
	}
	public void random(int val){ //Completely erases the contents of the board.
		//Array.Clear(map[cells], 0, map[cells].Length); //.net only?
		cells = 0;
		for(byte y = 1; y < height - 1; y++){
			for(byte x = 2; x < width - 1; x++){
				map[cells][y, x] = (byte)(GD.RandRange(0.0, 1.0) * val);
			}
		}
	}
	public void draw(Image img, Image glow_img) { //Default drawing with glows.
		byte cell = 0;
		for(byte y = 0; y < height; y++){
			for(byte x = 0; x < width; x++){
				cell = map[cells][y, x];
				if(cell != 0) {
					if(glows[cell]) glow_img.SetPixel(x, y, colors[cell]);
					else img.SetPixel(x, y, colors[cell]);
				}
			}
		}
	}
	public void draw_array(Image img, Godot.Collections.Array tmap, byte w, byte h) { //Draw plainly.
		int cell = 0;
		Godot.Collections.Array temp;
		for(byte y = 0; y < h; y++){
			temp = tmap[y] as Godot.Collections.Array;
			for(byte x = 0; x < w; x++){
				cell = (int)temp[x];
				if(cell != 0) img.SetPixel(x, y, colors[cell]);
			}
		}
	}
	virtual public byte rules(byte[,] omap, byte x, byte y){ //Override this with the actual rules.
		byte cell = omap[y,x];
		return cell;
	}
	public void line(int x0, int y0, int x1, int y1, byte brush){
		int dx = Mathf.Abs(x1 - x0);
		int dy = Mathf.Abs(y1 - y0);
		int sx = x0 > x1 ? -1 : 1;
		int sy = y0 > y1 ? -1 : 1;
		int err = (dx > dy ? dx : -dy) / 2;
		int er2 = 0;
		while(true) {
			map[cells][y0, x0] = brush;
			if (x0 == x1 && y0 == y1) return;
			er2 = err;
			if(er2 > -dx) { err -= dy; x0 += sx; }
			if(er2 < dy)  { err += dx; y0 += sy; }
		}
	}
	public Vector2 line_until(int x0, int y0, int x1, int y1, byte brush, byte stop){
		int dx = Mathf.Abs(x1 - x0);
		int dy = Mathf.Abs(y1 - y0);
		int sx = x0 > x1 ? -1 : 1;
		int sy = y0 > y1 ? -1 : 1;
		int err = (dx > dy ? dx : -dy) / 2;
		int er2 = 0;
		while(true) {
			if(map[cells][y0, x0] == stop){
				map[cells][y0, x0] = brush;
				return new Vector2(x0, y0);
			}
			if (x0 == x1 && y0 == y1) return new Vector2(-1, -1);
			er2 = err;
			if(er2 > -dx) { err -= dy; x0 += sx; }
			if(er2 < dy)  { err += dx; y0 += sy; }
		}
	}
	public override string ToString() {
		return $"Automaton: {name}";
	}
}
