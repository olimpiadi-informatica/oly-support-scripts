#{
  set page(flipped: true)
  let data = csv(sys.inputs.seating);
  let header = data.at(0);
  let data = data.slice(1);

  let username_idx = header.position(x => x == "username")
  let row_idx = header.position(x => x == "row")
  let col_idx = header.position(x => x == "col")
  let cells = ()
  let num_cols = 0;
  let num_rows = 0;
  for d in data {
    let row = int(d.at(row_idx));
    let col = d.at(col_idx);
    let col = col.to-unicode() - "A".to-unicode() + 1;
    if col > num_cols {
      num_cols = col;
    }
    if row > num_rows {
      num_rows = row;
    }
  }
  for d in data {
    let username = d.at(username_idx);
    if username == "free" { continue; }
    let row = int(d.at(row_idx));
    let col = d.at(col_idx);
    let col = col.to-unicode() - "A".to-unicode() + 1;
    cells.push(table.cell(x: num_rows - row + 1, y: col, text(weight: "bold", username)))
  }
  for i in range(0, num_cols) {
    cells.push(table.cell(x: 0, y: i + 1, str.from-unicode("A".to-unicode() + i)))
  }
  for i in range(0, num_rows) {
    cells.push(table.cell(y: 0, x: num_rows - i, str(i+1)))
  }
  table(
    columns: range(num_rows+1).map(_ => 1fr),
    rows: range(num_cols+1).map(_ => 1fr),
    align: horizon + center,
    ..cells
  )
}
