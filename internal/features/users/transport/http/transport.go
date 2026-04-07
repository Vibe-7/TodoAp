package user_transport_http

type UserHTTPHandler struct {
	usersService UserService
}

type UserService interface {
}

func NewUserHTTPHandler(usersService UserService) *UserHTTPHandler {
	return &UserHTTPHandler{
		usersService: usersService ,
	}
}