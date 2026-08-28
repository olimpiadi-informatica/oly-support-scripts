#let render(hostname, username, first_name, last_name) = {
  let background = image("x/background.png")
  let bg = luma(100)

  if username == "" {
    first_name = "BACKUP"
    bg = green
  }

  set page(
    width: 6.4in,
    height: 3.6in,
    margin: 0cm,
    background: rect(fill: bg, width: 100%, height: 100%)
  )

  set align(center)
  set text(fill: white)

  v(0.5em)

  image("logo.png", height: 1in)

  v(-3.5em)

  text(size: 5em, weight: "bold", if username != "" [
    #upper(hostname) -- #username
  ] else [
    #upper(hostname)
  ])

  v(-4em)

  text(size: 2em)[#first_name #last_name]
}

#{
  let seating = csv(sys.inputs.seating)
  let header = seating.at(0)
  let seating = seating.slice(1)

  let hostname_idx = header.position(x => x == "hostname")
  let username_idx = header.position(x => x == "username")
  let first_name_idx = header.position(x => x == "first_name")
  let last_name_idx = header.position(x => x == "last_name")

  for seat in seating {
    document(seat.at(hostname_idx) + ".png", render(
      seat.at(hostname_idx),
      seat.at(username_idx),
      seat.at(first_name_idx),
      seat.at(last_name_idx),
    ))
  }
}
