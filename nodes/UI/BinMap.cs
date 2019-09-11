using Godot;

public class BinMap: Control {
	private byte[,] map;
	private int width  = 1;
	private int height = 1;
	private Vector2 pix_size;
	private Vector2 cursor = new Vector2(0,0);
	[Export] Color fg = new Color("#FFFFFF");
	[Export] Color bg = new Color("#000000");
	[Export] Color hg = new Color("#00FF00");
	public override void _Ready() {
		GD.Print("[BinMap] OK");
	}
	public void init(int w, int h) {
		width = w; height = h;
		map = new byte[height, width];
		Update();
	}
	public override void _Draw() {
		pix_size.x = RectSize.x / width;
		pix_size.y = RectSize.y / height;
		DrawRect(new Rect2(0,0, RectSize.x, RectSize.y), bg);
		for(int y = 0; y < height; y++){
			for(int x = 0; x < width; x++){
				if(map[y, x] != 0) DrawRect(new Rect2(x*pix_size.x, y*pix_size.y, pix_size.x, pix_size.y), fg);
			}
		}
		DrawRect(new Rect2(cursor * pix_size, pix_size), hg, false);
	}
	public void set(int x, int y, byte val) {
		map[y,x] = val;
	}
}

//
//extends Control
//
//var map:Array
//var height:int = 0
//var width:int  = 0
//var pixel_size:Vector2
//export var fg:Color = "#FFFFFF"
//export var bg:Color = "#000000"
//export var hg:Color = "#00FF00"
//var cursor:Vector2 = Vector2(0,0)
//
//func init(w:int, h:int):
//	width = w
//	height = h
//	map = core.newMatrix2D(w, h)
//	update()
//
//func _draw() -> void:
//	pixel_size = Vector2(rect_size.x / width as float, rect_size.y / height as float)
//	draw_rect(Rect2(Vector2(0, 0), rect_size), bg)
//	for y in range(height):
//		for x in range(width):
//			if map[y][x]: draw_rect(Rect2(Vector2(x * pixel_size.x, y * pixel_size.y), pixel_size), fg)
//	draw_rect(Rect2(cursor * pixel_size,  pixel_size), hg, false)
