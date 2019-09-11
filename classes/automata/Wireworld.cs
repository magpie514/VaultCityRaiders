using Godot;
public class Wireworld: CellularAutomaton {
	override public void init(byte w, byte h, Godot.Collections.Dictionary vis) {
		width = w; height = h;
		//map = new byte[height, width];
		GD.Print("Initialized CA: Wireworld");
	}
}
