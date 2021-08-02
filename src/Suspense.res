@react.component
let make = (~children, ~error as fallbackError, ~loading) =>
  <RescriptReactErrorBoundary fallback={({error}) => fallbackError(error)}>
    <React.Suspense fallback=loading> {children} </React.Suspense>
  </RescriptReactErrorBoundary>
