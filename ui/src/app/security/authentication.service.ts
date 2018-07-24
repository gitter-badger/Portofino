import {Inject, Injectable, InjectionToken} from '@angular/core';
import {
  HttpClient,
  HttpEvent, HttpHandler, HttpHeaders, HttpInterceptor, HttpParams, HttpRequest
} from "@angular/common/http";
import {TokenStorageService} from "./token-storage.service";
import {MatDialog, MatDialogRef} from "@angular/material";
import {Observable, throwError} from "rxjs";
import { catchError, map, mergeMap } from "rxjs/operators";
import {PortofinoService} from "../portofino.service";
import {Router} from "@angular/router";

export const LOGIN_COMPONENT = new InjectionToken('Login Component');

@Injectable()
export class AuthenticationService {

  dialogRef: MatDialogRef<any>;
  currentUser: UserInfo;
  loginPath: string = "login";

  constructor(private http: HttpClient, protected dialog: MatDialog, protected storage: TokenStorageService,
              private portofino: PortofinoService, @Inject(LOGIN_COMPONENT) protected component,
              protected router: Router) {
    const displayName = this.storage.get('user.displayName');
    if(displayName) {
      this.currentUser = new UserInfo(displayName);
    }
  }

  request(req: HttpRequest<any>, observable: Observable<HttpEvent<any>>): Observable<HttpEvent<any>> {
    return observable.pipe(catchError((error) => {
      if (error.status === 401) {
        this.removeAuthenticationInfo();
        return this.askForCredentials().pipe(
          map(result => {
            if (!result) {
              throw new Error("User declined login");
            }
          }),
          mergeMap(_ => this.http.request(this.withAuthenticationHeader(req))));
      }
      return throwError(error);
    }));
  }

  protected askForCredentials() {
    if(!this.dialogRef) {
      this.dialogRef = this.dialog.open(this.component);
    }
    return this.dialogRef.afterClosed().pipe(map(result => {
      this.dialogRef = null;
      if (result && result.jwt) {
        this.setAuthenticationInfo(result);
        return result;
      } else {
        return null;
      }
    }));
  }

  public showLoginDialog() {
    this.askForCredentials().subscribe(result => {
      if(result) {
        this.router.navigateByUrl(this.router.url);
      }
    });
  }

  protected removeAuthenticationInfo() {
    this.storage.remove('jwt');
    this.storage.remove('user.displayName');
    this.storage.remove('sessionId');
    this.currentUser = null;
  }

  protected setAuthenticationInfo(result) {
    this.storage.set('jwt', result.jwt);
    this.storage.set('user.displayName', result.displayName);
    this.storage.set('sessionId', result.portofinoSessionId);
    this.currentUser = new UserInfo(result.displayName);
  }

  withAuthenticationHeader(req: HttpRequest<any>) {
    if(!this.storage.get('jwt')) {
      return req;
    }
    req = req.clone({
      setHeaders: {
        Authorization: `Bearer ${this.storage.get('jwt')}`
      }
    });
    return req;
  }

  login(username, password) {
    const headers = new HttpHeaders()
      .set('Content-Type', 'application/x-www-form-urlencoded')
      .set(NO_AUTH_HEADER, 'true');
    return this.http.post(
      `${this.portofino.apiPath}${this.loginPath}`,
      new HttpParams({fromObject: {"username": username, "password": password}}),
      {headers: headers}
    );
  }

  logout() {
    const url = `${this.portofino.apiPath}${this.loginPath}/${this.storage.get('sessionId')}`;
    this.http.delete(url).subscribe(value => {
      this.removeAuthenticationInfo();
      this.router.navigateByUrl(this.router.url);
    });
  }
}

@Injectable()
export class AuthenticationInterceptor implements HttpInterceptor {

  constructor(protected authenticationService: AuthenticationService) {}

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    req = this.authenticationService.withAuthenticationHeader(req);
    if(req.headers.has(NO_AUTH_HEADER)) {
      req = req.clone({ headers: req.headers.delete(NO_AUTH_HEADER) });
      return next.handle(req);
    } else {
      return this.authenticationService.request(req, next.handle(req));
    }
  }
}

export class UserInfo {
  constructor(public displayName: string) {}
}

export const NO_AUTH_HEADER = "portofino-no-auth";