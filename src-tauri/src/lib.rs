mod physics;
mod collision;
mod hole;
mod game;

use game::GameState;
use hole::create_uturn_hole;
use std::sync::Mutex;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
  let game_state = Mutex::new(GameState::new(create_uturn_hole()));

  tauri::Builder::default()
    .manage(game_state)
    .invoke_handler(tauri::generate_handler![
      init_game,
      update_game,
      strike_ball,
      reset_game,
      get_game_state,
    ])
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}

#[tauri::command]
fn init_game(state: tauri::State<Mutex<GameState>>) -> GameState {
  state.lock().unwrap().clone()
}

#[tauri::command]
fn update_game(state: tauri::State<Mutex<GameState>>, dt: f32) -> GameState {
  let mut game = state.lock().unwrap();
  game.update(dt);
  game.clone()
}

#[tauri::command]
fn strike_ball(state: tauri::State<Mutex<GameState>>, angle: f32, power: f32) {
  let mut game = state.lock().unwrap();
  game.strike(angle, power);
}

#[tauri::command]
fn reset_game(state: tauri::State<Mutex<GameState>>) -> GameState {
  let mut game = state.lock().unwrap();
  game.reset();
  game.clone()
}

#[tauri::command]
fn get_game_state(state: tauri::State<Mutex<GameState>>) -> GameState {
  state.lock().unwrap().clone()
}
