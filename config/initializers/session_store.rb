Rails.application.config.session_store :cookie_store,
                                         key: "_build_wise_pc_session",
                                         httponly: true,
                                         same_site: :lax
