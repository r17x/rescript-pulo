module Navbar = {
  open Chakra

  @react.component
  let make = () => <>
    <Center
      boxShadow=#var("--chakra-shadows-md")
      borderBottom={#border(#px(2), #solid, #var("--chakra-colors-gray-100"))}
      flexDir=#column
      zIndex=#sticky
      bg=#white
      position=#sticky
      top=#zero
      left=#zero
      right=#zero>
      <Link _hover={pseudo(~textDecoration=#none, ())} href=".">
        <Heading py=#two color=#hex("7AC88B")> {"Pulo.dev"->React.string} </Heading>
      </Link>
    </Center>
  </>
}

module Card = {
  open Chakra

  @react.component
  let make = (~url, ~title, ~media, ~mediaColor as colorScheme, ~author as name, ~description) =>
    <LinkBox _as="article">
      <Stack
      // TODO: {transition} for make animation
        borderRadius=#md p=#four _hover={pseudo(~boxShadow=#var("--chakra-shadows-md"), ())}>
        <Heading size=#sm my=#one>
          <LinkOverlay href=url isExternal=true> {title->React.string} </LinkOverlay>
        </Heading>
        <Text fontSize=#md noOfLines=#num(2)> {description->React.string} </Text>
        <HStack pt=#four>
          <Badge colorScheme> {media->React.string} </Badge>
          <Box flexGrow=#num(1.) />
          <Text fontSize=#sm> {name->React.string} </Text>
          <Avatar name size=#xs />
        </HStack>
      </Stack>
    </LinkBox>
}

module Error = {
  open Chakra
  let renderWithCode = code =>
    <Text my=#eight> {`Error :( ~ Sedih (Code: ${code->Js.Int.toString})`->React.string} </Text>

  @react.component
  let make = (~error) => <>
    {Api.Error.render(
      error,
      ~default=0->renderWithCode,
      ~decodeError=_ => 2->renderWithCode,
      ~jsError=_ => 3->renderWithCode,
      (),
    )}
  </>
}

let renderError = error => <Error error />

let isOptEqual = (currentMedia, media) =>
  switch currentMedia {
  | Some(currentMedia) => currentMedia == media
  | None => false
  }

module Media = {
  open Chakra

  @react.component
  let make = (~media, ~currentMedia, ~onClick as setMedia) => {
    let isCurrentMedia = isOptEqual(currentMedia)
    let handleClick = _ => setMedia(_ => media->isCurrentMedia ? None : Some(media))

    <Button
      textTransform=#uppercase
      size=#sm
      onClick={handleClick}
      isActive={media->isCurrentMedia ? #true_ : #false_}
      colorScheme={media->Api.Media.toColor}>
      {media->Api.Media.mediaToJs->React.string}
    </Button>
  }
}

module Filter = {
  open Chakra

  @react.component
  let make = () => {
    let (page, setPage) = Recoil.useRecoilState(Api.currentPage)
    let (currentMedia, onClick) = Api.useMedia()
    let handlePrevious = _ => setPage(prev => prev <= 1 ? 1 : prev - 1)
    let handleNext = _ => setPage(prev => prev + 1)
    let renderMedia = media => <Media media currentMedia onClick />

    <HStack
      boxShadow=#var("--chakra-shadows-sm")
      py=#eight
      position=#sticky
      zIndex=#sticky
      bg=#white
      bottom=#zero
      top=#zero
      left=#zero
      right=#zero
      justifyContent=#spaceBetween>
      <Button
        isDisabled={currentMedia->Belt.Option.isSome || page == 1 ? #true_ : #false_}
        onClick={handlePrevious}>
        {"Sebelumnya"->React.string}
      </Button>
      {Api.Media.media->Belt.List.map(renderMedia)->Belt.List.toArray->React.array}
      <Button isDisabled={currentMedia->Belt.Option.isSome ? #true_ : #false_} onClick={handleNext}>
        {"Selanjutnya"->React.string}
      </Button>
    </HStack>
  }
}

module Content = {
  open Chakra

  let renderCard = (content: Api.Content.t) =>
    <Card
      title=content.title
      description={content.body->Belt.Option.getWithDefault("---")}
      media={content.media->Api.Media.mediaToJs}
      mediaColor={content.media->Api.Media.toColor}
      author=content.contributor
      url=content.url
    />

  @react.component
  let make = () => {
    let contents = Api.useContent()

    <Container>
      <Stack spacing=#twelve>
        {contents->Belt.List.map(renderCard)->Belt.List.toArray->React.array}
      </Stack>
    </Container>
  }
}

open Chakra
@react.component
let make = () => <>
  <Navbar />
  <VStack>
    <Box minH=#vh(100.)>
      <Suspense
        error={renderError}
        loading={
          // TODO: jika binding dari {rescript-chakra} tersedia {Skeleton} or {Spinner}, GUNAKAN!!
          <Badge mt=#two colorScheme=#teal> {"Loading..."->React.string} </Badge>
        }>
        <Content />
      </Suspense>
    </Box>
    <Filter />
  </VStack>
</>
