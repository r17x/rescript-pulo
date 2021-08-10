/**
Dokumentasi dibawah ini, diambil dari halaman
@see <https://pulo.dev/api/>

API (Read Only)
[Semua Konten] https://api.pulo.dev/v1/contents

[Filter halaman] https://api.pulo.dev/v1/contents?page=NOMOR

[Filter media: bisa "web, tulisan, podcast atau video"] https://api.pulo.dev/v1/contents?media="$MEDIA"

[Filter Text] https://api.pulo.dev/v1/contents?query="$query"
*/

module Media = {
  @deriving(jsConverter)
  type media = [
    | #video
    | #web
    | #tulisan
    | #podcast
    | #tool
  ]

  let media = list{#video, #web, #tulisan, #podcast, #tool}

  let lazyMap = (media, video, web, tulisan, podcast, tool) =>
    switch media {
    | #video => video
    | #web => web
    | #tulisan => tulisan
    | #podcast => podcast
    | #tool => tool
    }

  let toColor = media => media->lazyMap(#red, #green, #teal, #yellow, #blue)

  let encoder = t => t->mediaToJs->Decco.stringToJson

  let decoder = json => {
    let descriminator = json->Decco.stringFromJson
    switch descriminator {
    | Ok("video") => Ok(#video)
    | Ok("web") => Ok(#web)
    | Ok("tulisan") => Ok(#tulisan)
    | Ok("podcast") => Ok(#podcast)
    | Ok("tool") => Ok(#tool)
    | _ =>
      Decco.error(
        `[Media] Expected JSON type is {string} with valid value "video" | "web" | "tulisan" | "podcast" `,
        json,
      )
    }
  }
  /**
  [codec] untuk membuat kostum [encoder] and [decoder] (fungsi), tepatnya mengatur response JSON menjadi type data {variant}
    @see <https://github.com/reasonml-labs/decco/issues/47#issuecomment-586024717>
 */
  let codec: Decco.codec<media> = (encoder, decoder)
  @decco
  type t = @decco.codec(codec) media
}

module Content = {
  @decco
  type t = {
    title: string,
    url: string,
    owner: string,
    body: option<string>,
    contributor: string,
    // alias field {created_at}
    @decco.key("created_at")
    createdAt: string,
    @decco.key("updated_at")
    updatedAt: option<string>,
    thumbnail: option<string>,
    media: Media.t,
  }
}

module Response = {
  @decco
  type t = {
    data: list<Content.t>,
    total: int,
  }
}

module Promise = {
  let then_ = (promise, callback) => Js.Promise.then_(callback, promise)
  let {resolve, reject} = module(Js.Promise)
}

module Error = {
  exception DecodeError(Decco.decodeError)
  let render = (error, ~default=React.null, ~decodeError=?, ~jsError=?, ()) =>
    switch (error, decodeError, jsError) {
    | (DecodeError(error), Some(decodeError), _) => decodeError(error)
    | (Js.Exn.Error(error), _, Some(jsError)) => jsError(error)
    | _ => default
    }
}

let getContent = (~params) => {
  let params = params->Js.Array2.map(((key, value)) => `${key}=${value}`)->Js.Array2.joinWith("&")
  let url = `https://api.pulo.dev/v1/contents?${params}`
  url
  ->Fetch.fetch
  ->Promise.then_(Fetch.Response.json)
  ->Promise.then_(json =>
    switch json->Response.t_decode {
    | Ok(result) => result.data->Promise.resolve
    | Error(e) => e->Error.DecodeError->raise->Promise.reject
    }
  )
}

let currentPage = Recoil.atom({
  key: "currentPage",
  default: 1,
})

let filter: Recoil.readWrite<option<Media.media>> = Recoil.atom({
  key: "filter",
  default: None,
})

let content = Recoil.asyncSelector({
  key: "content",
  get: ({get}) => {
    let params = switch filter->get {
    | Some(filter) => [("media", filter->Media.mediaToJs)]
    | None => [("page", currentPage->get->Js.Int.toString)]
    }

    getContent(~params)
  },
})

let useContent = () => Recoil.useRecoilValue(content)

let useMedia = () => Recoil.useRecoilState(filter)

let setPage = () => Recoil.useSetRecoilState(currentPage)

let nextPage = () => {
  let next = Recoil.useSetRecoilState(currentPage)
  next(prev => prev + 1)
}

let prevPage = () => {
  let next = Recoil.useSetRecoilState(currentPage)
  next(prev => prev <= 1 ? 1 : prev - 1)
}
