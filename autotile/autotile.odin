package autotile

import "core:fmt"


GRID_WIDTH := 0
GRID_HEIGHT := 0
BIT_GRID: []int


get_tile :: proc(x, y: int, grid: ^[]int) -> int {
    if x < 0 || y < 0 || x >= GRID_WIDTH || y >= GRID_HEIGHT {
        return 0
    }
    size := y * GRID_WIDTH + x
    return grid[size]
}

get_8bit_autotile_bit :: proc(x, y, tile_num: int, grid: ^[]int) -> int {
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

create_8bit_mask :: proc(grid: ^[]int) {
    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_HEIGHT {
            size := y * GRID_WIDTH + x
            if grid[size] == 1 {
                autotile := get_8bit_autotile_bit(x, y, 1, grid)
                BIT_GRID[size] = autotile
            } else {
                BIT_GRID[size] = 0
            }
        }
    }
}

get_4bit_autotile_bit :: proc(x,y, tile_num: int, grid: ^[]int) -> int {
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
}

create_4bit_mask :: proc(grid: ^[]int) {
    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_HEIGHT {
            size := y * GRID_WIDTH + x
            if grid[size] == 1 {
                autotile := get_4bit_autotile_bit(x, y, 1, grid)
                BIT_GRID[size] = autotile
            } else {
                BIT_GRID[size] = 0
            }
        }
    }
}

select_tile_type_8bit :: proc(x, y, bitmask: int) -> [2]int {
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
    if bitmask != 0 {
        fmt.println(bitmask)
    }
    return [2]int{0,0}
}

select_tile_type_4bit :: proc(x, y, bitmask: int) -> [2]int {
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
}

initialise_bit_level :: proc(width, height: int) {
    GRID_WIDTH = width
    GRID_HEIGHT = height
    BIT_GRID = make([]int, width*height)
}

clear_grid_memory :: proc() {
    delete(BIT_GRID)
}