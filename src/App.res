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

module Content = {
  open Chakra
  let toColor = media => media->Api.Media.lazyMap(#red, #green, #teal, #yellow)
  @react.component
  let make = () => {
    let contents = Api.useContent()
    let renderCard = (content: Api.Content.t) =>
      <Card
        title=content.title
        description={content.body->Belt.Option.getWithDefault("---")}
        media={content.media->Api.Media.mediaToJs}
        mediaColor={content.media->toColor}
        author=content.contributor
        url=content.url
      />

    <Container>
      <Stack spacing=#twelve>
        {contents->Belt.List.map(renderCard)->Belt.List.toArray->React.array}
      </Stack>
    </Container>
  }
}

@react.component
let make = () => {
  open Chakra
  <>
    <Navbar />
    <VStack>
      <React.Suspense
        fallback={
          // TODO: jika binding dari {rescript-chakra} tersedia {Skeleton} or {Spinner}, GUNAKAN!!
          <Badge mt=#two colorScheme=#teal> {"Loading..."->React.string} </Badge>
        }>
        <Content />
      </React.Suspense>
    </VStack>
  </>
}
