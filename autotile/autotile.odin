package autotile

import "core:fmt"
import rl "vendor:raylib"

Tile_Type :: enum {
    blob,
    wang_edge,
    wang_corner
}

Layer_Struct :: struct {
    key: int,
    bit: int
}

GRID_WIDTH := 0
GRID_HEIGHT := 0

get_tile :: proc(x, y: int, grid: ^[]int) -> int {
    if x < 0 || y < 0 || x >= GRID_WIDTH || y >= GRID_HEIGHT {
        return 0
    }
    size := y * GRID_WIDTH + x
    return grid[size]
}


get_autotile_bit :: proc(x,y, tile_num: int, grid: ^[]int, type: Tile_Type) -> int {
    if type == .wang_edge {
        bitmasks := [4]int{0,0,0,0}

        if get_tile(x,y-1, grid) == tile_num {
            bitmasks[0] = 1
        }
        if get_tile(x+1,y, grid) == tile_num {
            bitmasks[1] = 2
        }
        if get_tile(x,y+1, grid) == tile_num {
            bitmasks[2] = 4
        }
        if get_tile(x-1,y, grid) == tile_num {
            bitmasks[3] = 8
        }
        return bitmasks[0] + bitmasks[1] + bitmasks[2] + bitmasks[3]
    } else if type == .wang_corner {
        bitmasks := [4]int{0,0,0,0}
        if get_tile(x,y, grid) == tile_num {
            if get_tile(x+1,y-1, grid) == tile_num {
                bitmasks[0] = 1
            }
            if get_tile(x+1,y+1, grid) == tile_num {
                bitmasks[1] = 2
            }
            if get_tile(x-1,y+1, grid) == tile_num {
                bitmasks[2] = 4
            }
            if get_tile(x-1,y-1, grid) == tile_num {
                bitmasks[3] = 8
            }
    
            if get_tile(x, y-1, grid) == tile_num && get_tile(x+1, y, grid) == tile_num {
                bitmasks[0] = 1
            }
            if get_tile(x, y+1, grid) == tile_num && get_tile(x+1, y, grid) == tile_num {
                bitmasks[1] = 2
            } 
            if get_tile(x, y+1, grid) == tile_num && get_tile(x-1, y, grid) == tile_num {
                bitmasks[2] = 4
            }
            if get_tile(x, y-1, grid) == tile_num && get_tile(x-1, y, grid) == tile_num {
                bitmasks[3] = 8
            }
        } else {
            if get_tile(x, y-1, grid) == tile_num && get_tile(x+1, y, grid) == tile_num {
                bitmasks[0] = 1
            }
            if get_tile(x, y+1, grid) == tile_num && get_tile(x+1, y, grid) == tile_num {
                bitmasks[1] = 2
            } 
            if get_tile(x, y+1, grid) == tile_num && get_tile(x-1, y, grid) == tile_num {
                bitmasks[2] = 4
            }
            if get_tile(x, y-1, grid) == tile_num && get_tile(x-1, y, grid) == tile_num {
                bitmasks[3] = 8
            }
        }

        return bitmasks[0] + bitmasks[1] + bitmasks[2] + bitmasks[3]
    } else {
        bitmasks := [8]int{0,0,0,0,0,0,0,0}
    
        if get_tile(x, y-1, grid) == tile_num {
            bitmasks[0] = 1  // North
        }
        if get_tile(x+1, y-1, grid) == tile_num {
            bitmasks[1] = 2  // North-East
        }
        if get_tile(x+1, y, grid) == tile_num {
            bitmasks[2] = 4 // East
        }
        if get_tile(x+1, y+1, grid) == tile_num {
            bitmasks[3] = 8  // South-East
        }
        if get_tile(x, y+1, grid) == tile_num {
            bitmasks[4] = 16  // South
        }
        if get_tile(x-1, y+1, grid) == tile_num {
            bitmasks[5] = 32  // South-West
        }
        if get_tile(x-1, y, grid) == tile_num {
            bitmasks[6] = 64  // West
        }
        if get_tile(x-1, y-1, grid) == tile_num {
            bitmasks[7] = 128  // North-West
        }
    
        if bitmasks[1] > 0 && bitmasks[0] == 0 || bitmasks[2] == 0 {
            bitmasks[1] = 0
        }
        if bitmasks[3] > 0 && bitmasks[2] == 0 || bitmasks[4] == 0 {
            bitmasks[3] = 0
        }
        if bitmasks[5] > 0 && bitmasks[4] == 0 || bitmasks[6] == 0{
            bitmasks[5] = 0
        }
        if bitmasks[7] > 0 && bitmasks[6] == 0 || bitmasks[0] == 0 {
            bitmasks[7] = 0
        }
    
        return bitmasks[0] + bitmasks[1] + bitmasks[2] + bitmasks[3] + bitmasks[4] + bitmasks[5] + bitmasks[6] + bitmasks[7]
    }
}

create_bit_mask :: proc(grid: ^[]int, key: int, type: Tile_Type) -> []int {
    bit_grid := make([]int, GRID_WIDTH*GRID_HEIGHT)

    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_HEIGHT {
            size := y * GRID_WIDTH + x
            if type == .wang_corner {
                autotile := get_autotile_bit_marching(x, y, key, grid)
                bit_grid[size] = autotile
            } else if type == .wang_corner || grid[size] == key {
                autotile := get_autotile_bit(x, y, key, grid, type) 
                bit_grid[size] = autotile
            } else {
                bit_grid[size] = 0
            }
        }
    }

    return bit_grid
}

get_autotile_bit_marching :: proc(x,y, tile_num: int, grid: ^[]int) -> int {
    bitmasks := [4]int{0,0,0,0}
    
    if get_tile(x,y, grid) == tile_num {
        bitmasks[0] = 8
    }
    if get_tile(x+1, y, grid) == tile_num {
        bitmasks[1] = 1
    }
    if get_tile(x+1, y+1, grid) == tile_num {
        bitmasks[2] = 2
    }
    if get_tile(x, y+1, grid) == tile_num {
        bitmasks[3] = 4
    }

    return bitmasks[0] + bitmasks[1] + bitmasks[2] + bitmasks[3]
}

create_bitmask_layered :: proc(grid: ^[]int, keys: []int, type: Tile_Type) -> [][]Layer_Struct {
    bit_grid := make([][]Layer_Struct, GRID_WIDTH*GRID_HEIGHT)
    
    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_HEIGHT {
            for key, index in keys {
                size := y * GRID_WIDTH + x
                autotile := 0
                if type == .wang_corner {
                    autotile = get_autotile_bit_marching(x, y, key, grid)
                } else if grid[size] == key {
                    autotile = get_autotile_bit(x, y, key, grid, type) 
                }

                length := len(bit_grid[size])
                if autotile != 0 {
                    if length == 0 {
                        bit_grid[size] = make([]Layer_Struct, 1)
                        bit_grid[size][0] = Layer_Struct{
                            key=key,
                            bit=autotile
                        }
                    } else {
                        new := make([]Layer_Struct, length+1)
                        copy(new, bit_grid[size][:])
                        new[length] = Layer_Struct{
                            key=key,
                            bit=autotile
                        }
                        delete(bit_grid[size])
                        bit_grid[size] = make([]Layer_Struct, length+1)
                        copy(bit_grid[size], new[:])
                        delete(new)
                    }
                }
            }
        }
    }

    
    return bit_grid
}

create_bitmask_textures :: proc(texture: cstring, keys: [][3]int, cell_size: i32, grid: ^[]int, start_row: i32) {
    bit_values := make([][]int, len(keys))
    defer delete(bit_values)
    combos: [dynamic][3]int
    defer delete(combos)

    for key, index in keys {
        bit_values[index] = create_bit_mask(grid, key[0], .wang_corner)
    }

    texture_image := rl.LoadImage(texture)
    defer rl.UnloadImage(texture_image)
    
    canvas := rl.GenImageColor(texture_image.width, texture_image.height*10, rl.BLANK)
    defer rl.UnloadImage(canvas)

    rl.ImageDraw(&canvas, texture_image, 
        rl.Rectangle{0, 0, f32(texture_image.width), f32(texture_image.height)},
        rl.Rectangle{0, 0, f32(texture_image.width), f32(texture_image.height)},
        rl.WHITE
    )

    used_positions: [dynamic][2]int
    col_amount := texture_image.width/cell_size
    cur_col :i32= 0
    cur_row :i32= start_row

    for i in 0..<len(bit_values)-1 {
        for bit, index in bit_values[i] {
            bit2 := bit_values[i+1][index]
            if bit != 0 && bit2 != 0 && bit != 15 && bit2 != 15 {
                if bit == bit2 {
                    continue
                }

                exists := false
                for c in combos {
                    if c[0] == i+1 && c[1] == bit && c[2] == bit2 {
                        exists = true
                        break
                    }
                } 

                if exists {
                    continue
                }
                p1 := select_tile_type(bit, .wang_corner)
                t1_pos := [2]int{p1[0]+keys[i][1], p1[1]+keys[i][2]}
                source_rect1 := rl.Rectangle{
                    x=f32(t1_pos[0]*32),
                    y=f32(t1_pos[1]*32),
                    width=32,
                    height=32
                }

                p2 := select_tile_type(bit2, .wang_corner)
                t2_pos := [2]int{p2[0]+keys[i+1][1], p1[1]+keys[i+1][2]}
                source_rect2 := rl.Rectangle{
                    x=f32(t2_pos[0]*32),
                    y=f32(t2_pos[1]*32),
                    width=32,
                    height=32
                }

                dest_position := [2]f32{
                    f32(cur_col*cell_size),
                    f32(cur_row*cell_size)
                }

                portion1 := rl.ImageFromImage(texture_image, source_rect1)
                portion2 := rl.ImageFromImage(texture_image, source_rect2)
                rl.ImageDraw(&canvas, portion2, rl.Rectangle{0,0,f32(portion2.width), f32(portion2.height)},
                    rl.Rectangle{dest_position.x, dest_position.y, f32(portion2.width), f32(portion2.height)},
                    rl.WHITE
                )
                rl.ImageDraw(&canvas, portion1, rl.Rectangle{0,0,f32(portion1.width), f32(portion1.height)},
                    rl.Rectangle{dest_position.x, dest_position.y, f32(portion1.width), f32(portion1.height)},
                    rl.WHITE
                )
                rl.UnloadImage(portion1)
                rl.UnloadImage(portion2)

                if cur_col > col_amount {
                    cur_col = 0
                    cur_row += 1
                } else {
                    cur_col += 1
                }

                append(&combos, [3]int{i+1, bit, bit2})
            }
        }
        clear(&combos)
    }

    for b in bit_values {
        delete(b)
    }

    rl.ExportImage(canvas, "extended_transparent_image.png")
}

select_tile_type :: proc(bitmask: int, type: Tile_Type) -> [2]int {
    if type == .wang_edge {
        switch bitmask {
            case 4:
                return [2]int{0,0}
            case 6:
                return [2]int{1,0}
            case 14:
                return [2]int{2,0}
            case 12:
                return [2]int{3,0}
            case 5:
                return [2]int{0,1}
            case 7:
                return [2]int{1,1}
            case 15:
                return [2]int{2,1}
            case 13:
                return [2]int{3,1}
            case 1:
                return [2]int{0,2}
            case 3:
                return [2]int{1,2}
            case 11:
                return [2]int{2,2}
            case 9:
                return [2]int{3,2}
            case 2:
                return [2]int{1,3}
            case 10:
                return [2]int{2,3}
            case 8:
                return [2]int{3,3}
        }
        return [2]int{0,3}
    } else if type == .wang_corner {
        switch bitmask {
            case 4:
                return [2]int{0,0}
            case 3:
                return [2]int{1,0}
            case 14:
                return [2]int{2,0}
            case 6:
                return [2]int{3,0}
            case 10:
                return [2]int{0,1}
            case 7:
                return [2]int{1,1}
            case 15:
                return [2]int{2,1}
            case 13:
                return [2]int{3,1}
            case 1:
                return [2]int{0,2}
            case 9:
                return [2]int{1,2}
            case 11:
                return [2]int{2,2}
            case 12:
                return [2]int{3,2}
            case 2:
                return [2]int{1,3}
            case 5:
                return [2]int{2,3}
            case 8:
                return [2]int{3,3}
        }
        return [2]int{0,3}
    } else {
        switch bitmask {
            case 4:
                return [2]int{1,0}
            case 92:
                return [2]int{2,0}
            case 124:
                return [2]int{3,0}
            case 116:
                return [2]int{4,0}
            case 80:
                return [2]int{5,0}
            case 16:
                return [2]int{0,1}
            case 20:
                return [2]int{1,1}
            case 87:
                return [2]int{2,1}
            case 223:
                return [2]int{3,1}
            case 241:
                return [2]int{4,1}
            case 21:
                return [2]int{5,1}
            case 64:
                return [2]int{6,1}
            case 29:
                return [2]int{0,2}
            case 117:
                return [2]int{1,2}
            case 85:
                return [2]int{2,2}
            case 71:
                return [2]int{3,2}
            case 221:
                return [2]int{4,2}
            case 125:
                return [2]int{5,2}
            case 112:
                return [2]int{6,2}
            case 31:
                return [2]int{0,3}
            case 253:
                return [2]int{1,3}
            case 113:
                return [2]int{2,3}
            case 28:
                return [2]int{3,3}
            case 127:
                return [2]int{4,3}
            case 247:
                return [2]int{5,3}
            case 209:
                return [2]int{6,3}
            case 23:
                return [2]int{0,4}
            case 199:
                return [2]int{1,4}
            case 213:
                return [2]int{2,4}
            case 95:
                return [2]int{3,4}
            case 255:
                return [2]int{4,4}
            case 245:
                return [2]int{5,4}
            case 81:
                return [2]int{6,4}
            case 5:
                return [2]int{0,5}
            case 84:
                return [2]int{1,5}
            case 93:
                return [2]int{2,5}
            case 119:
                return [2]int{3,5}
            case 215:
                return [2]int{4,5}
            case 193:
                return [2]int{5,5}
            case 17:
                return [2]int{6,5}
            case 1:
                return [2]int{1,6}
            case 7:
                return [2]int{2,6}
            case 197:
                return [2]int{3,6}
            case 69:
                return [2]int{4,6}
            case 68:
                return [2]int{5,6}
            case 65:
               return [2]int{6,6}
        }
        return [2]int{0,0}
    }
}

initialise_bit_level :: proc(width, height: int) {
    GRID_WIDTH = width
    GRID_HEIGHT = height
}