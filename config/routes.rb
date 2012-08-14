Openvoc::Application.routes.draw do
  root to: 'static_pages#home'
  match '/contact', to: 'static_pages#contact'
end
