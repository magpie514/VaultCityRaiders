using Godot;
public class WireworldRGB: CellularAutomaton {
	const byte STATES = 10;
	const byte NULL = 0;
	const byte HEAD_R = 1; const byte TAIL_R = 2; const byte WIRE_R = 3;
	const byte HEAD_G = 4; const byte TAIL_G = 5; const byte WIRE_G = 6;
	const byte HEAD_B = 7; const byte TAIL_B = 8; const byte WIRE_B = 9;
	override public void init(byte w, byte h, Godot.Collections.Dictionary vis) {
		states = new byte[STATES]{ NULL, HEAD_R, TAIL_R, WIRE_R, HEAD_G, TAIL_G, WIRE_G, HEAD_B, TAIL_B, WIRE_B };
		glows  = new bool[STATES]{ false, true, true, false, true, true, false, true, true, false };
		colors = new Color[STATES];
		no_op = NULL;
		base.init(w, h, vis);
		GD.Print("Initialized CA: WireworldRGB");
	}
	override public byte rules(byte[,] omap, byte x, byte y){
		byte cell = omap[y, x];
		switch(cell){
			case HEAD_R: return TAIL_R;
			case HEAD_G: return TAIL_G;
			case HEAD_B: return TAIL_B;
			case TAIL_R: return WIRE_R;
			case TAIL_G: return WIRE_G;
			case TAIL_B: return WIRE_B;
			case WIRE_R: {
				int neighbors_r = 0;
				int neighbors_b = 0;
				int[] off;
				for(int i = 0; i < moore.GetLength(0); i++){
					off = moore[i];
					if(omap[y+off[0], x+off[1]] == HEAD_R) neighbors_r++;
					if(omap[y+off[0], x+off[1]] == HEAD_B) neighbors_b++;
				}
				if (neighbors_r == 1 || neighbors_r == 2) return HEAD_R;
				else if (neighbors_b == 1 || neighbors_b == 2) return HEAD_R;
				return WIRE_R;
			}
			case WIRE_G: {
				int neighbors_r = 0;
				int neighbors_g = 0;
				int[] off;
				for(int i = 0; i < moore.GetLength(0); i++){
					off = moore[i];
					if(omap[y+off[0], x+off[1]] == HEAD_R) neighbors_r++;
					if(omap[y+off[0], x+off[1]] == HEAD_G) neighbors_g++;
				}
				if (neighbors_g == 1)      return HEAD_G;
				else if (neighbors_r == 1) return HEAD_G;
				return WIRE_G;
			}
			case WIRE_B: {
				int neighbors_b = 0;
				int neighbors_g = 0;
				int[] off;
				for(int i = 0; i < moore.GetLength(0); i++){
					off = moore[i];
					if(omap[y+off[0], x+off[1]] == HEAD_B) neighbors_b++;
					if(omap[y+off[0], x+off[1]] == HEAD_G) neighbors_g++;
				}
				if (neighbors_b == 2)                          return HEAD_B;
				else if (neighbors_g == 1 && neighbors_b == 0) return HEAD_B;
				return WIRE_B;
			}
			default:
				return cell;
		}
	}
}
