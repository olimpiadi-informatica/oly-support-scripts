#{
  let hostname = sys.inputs.hostname;
  let data = csv(sys.inputs.seating);
  let header = data.at(0);
  let data = data.slice(1);

  let last_name_idx = header.position(x => x == "last_name")
  let first_name_idx = header.position(x => x == "first_name")
  let username_idx = header.position(x => x == "username")
  let hostname_idx = header.position(x => x == "hostname")
  let row_idx = header.position(x => x == "row")
  let col_idx = header.position(x => x == "col")



  let (last_name, first_name, username) = ("", "", "");

  for arr in data {
    let found = false;
    let found = if hostname_idx != none {
      arr.att(hostname_idx) == hostname
    } else {
      assert(row_idx != none);
      assert(col_idx != none);
      let poscode = hostname.split("-").at(-1);
      let row = int(poscode.slice(1));
      let col = poscode.at(0);
      int(arr.at(row_idx)) == row and lower(arr.at(col_idx)) == lower(col)
    }
    if found {
      last_name = arr.at(last_name_idx);
      first_name = arr.at(first_name_idx);
      username = arr.at(username_idx);
    }
  }

  let (contestant, bg) = if last_name != "" {
    ([#first_name #last_name (#raw(username))], luma(100))
  } else {
    ([BACKUP], green)
  };

  set page(
    width: 6.4in,
    height: 3.6in,
    margin: 0cm,
    background: rect(fill: bg, width: 100%, height: 100%)
  )

  place(
    center + top,
    dy: 0.2in,
    [
      #text(fill: white, size: 5em, upper(hostname)) \
      #v(0.5em)
      #text(fill: white, size: 2em, contestant) \
      #image(sys.inputs.logo, height: 1.7in)
    ]
  )
}
