package main

import (
	"github.com/mikespook/golib/log"
	"github.com/mikespook/possum"
	"github.com/mikespook/possum/router"
	"github.com/mikespook/possum/view"
)

const (
	ResponseAccess      = "A"
	ResponseDeny        = "D"
	ResponseFurtherAuth = "S"
)

func init() {
	mux.HandleFunc(router.Simple("/access"), access, view.Simple("text/plain", "utf-8"))
	mux.HandleFunc(router.Simple("/log"), logMsg, view.Simple("text/plain", "utf-8"))
}

func access(ctx *possum.Context) error {
	ap := ctx.Request.FormValue("ap")
	uid := ctx.Request.FormValue("uid")
	log.Debugf("From %0X got %0X", []byte(ap), []byte(uid))
	ctx.Response.Data = ResponseAccess
	return nil
}

func logMsg(ctx *possum.Context) error {
	ap := ctx.Request.FormValue("ap")
	log.Debugf("From %0X", []byte(ap))
	return nil
}
